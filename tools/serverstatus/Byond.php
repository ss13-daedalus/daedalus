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
   [Status] => Done              // Should only return 'Done' or 'Error'.  If 'Error', there will be another
                                 // field, 'Error', in the array with a summary of the problem.
)

It will also drop a file in the working directory with the format '.hostname-port.dat' (e. g. '.deadalus.example.com-12345.dat')
which containes serialize()d data which is used if the file is less than the defined min_server_age number of seconds old.  This
will prevent the use of this class in a frequently used tool from causing repeated calls to the server in a short span of time.

 */

   private $address = Null;
   private $port = Null;
   private $min_server_age = 120;      // Minimum age of the server status data.  Seconds.
   private $socket = Null;
   private $query = Null;
   private $raw_data = Null;
   private $array_data = array(
      'Version'      => Null,
      'Mode'         => Null,
      'Respawn'      => Null,
      'Join'         => Null,
      'Voting'       => Null,
      'AI'           => Null,
      'Host'         => Null,
      'NumPlayers'   => Null,
      'Admins'       => Null,
      'Players'      => Null,
      'Status'       => 'Uninitialized' );

   public function configure( $host = Null, $port = Null ) {
      if( is_null( $host ) || is_null( $port ) || ! is_numeric( $port ) ) {
         return False;
      }
      $this->address = $host;
      $this->port = $port;
      $this->array_data['Status'] = 'Configured';
      return True;
   }  // Setup

   public function getInfo( $query = Null ) {
      if( ! $this->probe( $query ) ) {
         $this->array_data['Status'] = 'Error';
         $this->array_data['Error'] = "Probing byond://$this->address:$this->port failed.";
      }
      return $this->array_data;
   }  // getStatus()

   private function configured() {
      if( $this->array_data['Status'] != 'Configured' ) {
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
      return $this->transform( $this->parse( $this->raw_data ) );
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
         $this->array_data['Status'] = 'Error';
         $this->array_data['Error'] = 'Unable to connect to  socket.';
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
      $datfile = '.' . $this->address . '-' . $this->port . '.dat';
      if( ! file_exists( $datfile ) || ( time() - filemtime( $datfile ) >= 120 ) ) {
         $this->connect();
         $bytes_total = strlen( $this->query );
         $bytes_sent = 0;
         while( $bytes_sent < $bytes_total ) {
            $result = socket_write( $this->socket, substr( $this->query, $bytes_sent), $bytes_total - $bytes_sent );
            if( $result === False) {
               $this->array_data['Status'] = 'Error';
               $this->array_data['Error'] = socket_strerror( socket_last_error() );
               return False;
            }
            $bytes_sent += $result;
         }  // while
         $result = socket_read( $this->socket, 10000, PHP_BINARY_READ);
         $this->disconnect();
         $this->raw_data = $result;
         if( file_exists( $datfile ) ) {
            unlink( $datfile );
         }
         file_put_contents( $datfile, serialize( $this->raw_data ) );
         $this->array_data['Status'] = 'Read';
         return True;
      } else {
         $this->raw_data = unserialize( file_get_contents( $datfile ) );
         $this->array_data['Status'] = 'Cached';
         return True;
      }
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
      } else {
         $this->array_data['Status'] = 'Error';
         $this->array_data['Error'] = 'Null data';
         return Null;
      }
   }  // parse()

   private function transform( $data = Null ) {
      if( ! ( $this->array_data['Status'] == 'Read' || $this->array_data['Status'] == 'Cached' ) || ! is_string( $data ) ) {
         $this->array_data['Status'] = 'Error';
         $this->array_data['Error'] = 'Attempted to transform null data, or data not read before transform.';
         return False;
      }
      $data = str_replace("\x00", "", $data);                     // remove pesky null-terminating bytes

      // Split the information into easily-accessible arrays
      $array_data = explode("&", $data);
      $data_length = count($array_data);
      for($i = 0; $i < $data_length; $i++) {
         $array_data[$i] = explode("=", $array_data[$i]); // split indexes into two arrays when = operator is present
      }
      $this->array_data['Version'] = str_replace( '+', ' ', $array_data[0][1] );
      $this->array_data['Mode'] = $array_data[1][1];
      $this->array_data['Respawn'] = $array_data[2][1];
      $this->array_data['Join'] = $array_data[3][1];
      $this->array_data['Voting'] = $array_data[4][1];
      $this->array_data['AI'] = $array_data[5][1];
      @$this->array_data['Host'] = $array_data[6][1];              // The @ will supress errors for hosts that return null host names
      $this->array_data['NumPlayers'] = $array_data[7][1] - 1;     // BYOND reports 1 + number of players.
      $this->array_data['Admins'] = $array_data[8][1];
      $this->array_data['Players'] = array();
      for( $i = 9; $i < sizeof( $array_data ) - 1; $i++) {         // After the player list is a "%23end" marker.
         if( ! empty( $array_data[$i][1] ) ) {
            $this->array_data['Players'][] = str_replace( "+", " ", $array_data[$i][1] );
         }
      }
      $this->array_data['Status'] = 'Done';
      return True;
   }  // transform()

}  // Byond

?>
