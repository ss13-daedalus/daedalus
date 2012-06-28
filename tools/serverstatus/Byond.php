<?php

class Byond {

/*
 === Example usage: ===


$server = new Byond;
$server->configure( 'deadalus.exmaple.com', 12345 );
print_r( $server->getInfo( 'status' ) );

The above code will output something much like the following:
  
Array
(
   [Version] => Daedalus         // The 'version' of the codebase as reported ot the BYOND Hub
   [Mode] => secret              // The current game mode (e. g. 'secret', 'extended', 'traitor')
   [Respawn] => 1                // 1 if Respawning is allowed; 0 otherwise.  (May change to True/False)
   [Join] => 1                   // 1 if players can join the server; 0 otherwise
   [Voting] => 1                 // 1 if Votes (e. g. for restarts) are permitted; 0 otherwise
   [AI] => 1                     // 1 if AI is an allowed role; 0 otherwise
   [Host] => Yournamehere        // The contents of the HOSTEDBY setting in config/config.txt
   [NumPlayers] => 0             // The number of players connected
   [Admins] => 0                 // 1 if an Admin is online; 0 elsewise.  "Stealth" admins don't count.
   [Players] => Array            // An array containing the BYOND keys of all connected players, or an empty array
      (
      )
)
 */

   private $address = Null;
   private $port = Null;
   private $socket = Null;
   private $query = Null;
   private $raw_data = Null;
   private $array_data = Null;

   public function configure( $host = Null, $port = Null ) {
      if( is_null( $host ) || is_null( $port ) || ! is_numeric( $port ) ) {
         return False;
      }
      $this->address = $host;
      $this->port = $port;
      return True;
   }  // Setup

   public function getInfo( $query = Null ) {
      $this->probe( $query );
      return $this->array_data;
   }  // getStatus()

   private function configured() {
      if( is_null( $this->address) || is_null( $this->port ) ) {
         return False;
      } else {
         return True;
      }
   }  // configured()

   private function probe( $query = Null ) {
      if(! $this->configured() ) {
         return False;
      }
      $this->query = $this->assemble_query( $query );
      $this->get_data();
      $this->transform( $this->parse( $this->raw_data ) );
   }  // probe()

   private function assemble_query( $query_string = '?status' ) {
      // Make sure query string starts with an interrogation mark
      if( $query_string{0} != '?') {
         $query_string = '?' . $query_string;
      }
      return "\x00\x83" . pack( 'n', strlen( $query_string) + 6 ) . "\x00\x00\x00\x00\x00" . $query_string . "\x00";
   }  // assemble_query()

   private function connect() {
      if( ! $this->configured() ) {
         return False;
      }

      $this->socket = socket_create( AF_INET, SOCK_STREAM, SOL_TCP) or die( 'Unable to create socket.' );
      if( ! socket_connect( $this->socket, $this->address, $this->port ) ) {
         return False;
      } else {
         // Set two second timeout on socket read and write
         socket_set_option( $this->socket, SOL_SOCKET, SO_RCVTIMEO, array( "sec" => 2, "usec" => 0 ) );
         socket_set_option( $this->socket, SOL_SOCKET, SO_SNDTIMEO, array( "sec" => 2, "usec" => 0 ) );
         return True;
      }
   }  // connect()

   private function disconnect() {
      if( ! $this->configured() && ( ! is_null( $this->socket ) ) ) {
         return False;
      }
      return socket_close( $this->socket );
   }  // disconnect()

   private function get_data() {
      if( ! $this->configured() ) {
         return False;
      }
      $this->connect();
      $bytes_total = strlen( $this->query );
      $bytes_sent = 0;
      while( $bytes_sent < $bytes_total ) {
         $result = socket_write( $this->socket, substr( $this->query, $bytes_sent), $bytes_total - $bytes_sent );
         if( $result === False) {
            die( socket_strerror( socket_last_error() ) );
         }
         $bytes_sent += $result;
      }  // while
      $result = socket_read( $this->socket, 10000, PHP_BINARY_READ);
      $this->disconnect();
      $this->raw_data = $result;
      return True;
   }  // get_data()

   private function parse( $data ) {
      if($data != "") {
         if($data{0} == "\x00" || $data{1} == "\x83") {           // make sure it's the right packet format

            // Actually begin reading the output:
            $sizebytes = unpack('n', $data{2} . $data{3});        // array size of the type identifier and content
            $size = $sizebytes[1] - 1;                            // size of string/floating-point, less the identifier byte

            if($data{4} == "\x2a") {                              // 4-byte big-endian floating-point
                                                                  // 4 possible bytes: add them up together, unpack them
                                                                  // as a floating-point
               $unpackint = unpack('f', $data{5} . $data{6} . $data{7} . $data{8}); 
               return $unpackint[1];
            }
            else if($data{4} == "\x06") {                         // ASCII string
               $unpackstr = "";                                   // Initialize result string
               $index = 5;                                        // string index

               while($size > 0) {                                 // loop through the entire ASCII string
                  $size--;
                  $unpackstr .= $data{$index};                    // add the string position to return string
                  $index++;
               }
               return $unpackstr;
            }
         }
      }     

   }  // parse()

   private function transform( $data = Null ) {
      if( ! $this->configured() || ! is_string( $data ) ) {
         return False;
      }
      $data = str_replace("\x00", "", $data);                     // remove pesky null-terminating bytes

      // Split the information into easily-accessible arrays
      $data_array = explode("&", $data);
      $data_length = count($data_array);
      for($i = 0; $i < $data_length; $i++) {
         $data_array[$i] = explode("=", $data_array[$i]); // split indexes into two arrays when = operator is present
      }
      $completed_array = array();
      $completed_array['Version'] = str_replace( '+', ' ', $data_array[0][1] );
      $completed_array['Mode'] = $data_array[1][1];
      $completed_array['Respawn'] = $data_array[2][1];
      $completed_array['Join'] = $data_array[3][1];
      $completed_array['Voting'] = $data_array[4][1];
      $completed_array['AI'] = $data_array[5][1];
      @$completed_array['Host'] = $data_array[6][1];              // The @ will supress errors for hosts that return null host names
      $completed_array['NumPlayers'] = $data_array[7][1] - 1;     // BYOND reports 1 + number of players.
      $completed_array['Admins'] = $data_array[8][1];
      $completed_array['Players'] = array();
      for( $i = 9; $i < sizeof( $data_array ) - 1; $i++) {        // After the player list is a "%23end" marker.
         if( ! empty( $data_array[$i][1] ) ) {
            $completed_array['Players'][] = str_replace( "+", " ", $data_array[$i][1] );
         }
      }
      $this->array_data = $completed_array;
      return True;
   }  // transform()

}  // Byond

?>
