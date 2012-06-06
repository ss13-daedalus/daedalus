<?php

ini_set('display_errors', 0); // to prevent error stacks from showing; just show the error message in the generated image instead


function export($addr, $port, $str) {

   // All queries must begin with a question mark (ie "?players")
   if($str{0} != '?') $str = ('?' . $str);

   /* --- Prepare a packet to send to the server (based on a reverse-engineered packet structure) --- */
   $query = "\x00\x83" . pack('n', strlen($str) + 6) . "\x00\x00\x00\x00\x00" . $str . "\x00";

   /* --- Create a socket and connect it to the server --- */
   $server = socket_create(AF_INET,SOCK_STREAM,SOL_TCP) or die('Unable to create export socket.');
   if(!socket_connect($server,$addr,$port)) {
      return "ERROR";
   }


   /* --- Send bytes to the server. Loop until all bytes have been sent --- */
   $bytestosend = strlen($query);
   $bytessent = 0;
   while ($bytessent < $bytestosend) {
      //echo $bytessent.'<br>';
      $result = socket_write($server,substr($query,$bytessent),$bytestosend-$bytessent);
      //echo 'Sent '.$result.' bytes<br>';
      if ($result===FALSE) die(socket_strerror(socket_last_error()));
      $bytessent += $result;
   }

   /* --- Idle for a while until recieved bytes from game server --- */
   $result = socket_read($server, 10000, PHP_BINARY_READ);
   socket_close($server); // we don't need this anymore

   if($result != "") {
      if($result{0} == "\x00" || $result{1} == "\x83") { // make sure it's the right packet format

         // Actually begin reading the output:
         $sizebytes = unpack('n', $result{2} . $result{3}); // array size of the type identifier and content
         $size = $sizebytes[1] - 1; // size of the string/floating-point (minus the size of the identifier byte)

         if($result{4} == "\x2a") { // 4-byte big-endian floating-point
            $unpackint = unpack('f', $result{5} . $result{6} . $result{7} . $result{8}); // 4 possible bytes: add them up together, unpack them as a floating-point
            return $unpackint[1];
         }
         else if($result{4} == "\x06") { // ASCII string
            $unpackstr = ""; // result string
            $index = 5; // string index

            while($size > 0) { // loop through the entire ASCII string
               $size--;
               $unpackstr = $unpackstr . $result{$index}; // add the string position to return string
               $index++;
            }
            return $unpackstr;
         }
      }
   }     
}
// Connection settings:


$addr = "game.nanotrasen.com";
$port = 1337;
$servername = "/tg/ Station 13";



// Export information to the game server and grab any information
$data = export($addr, $port, '?status');
if(is_string($data)) {
   $data = str_replace("\x00", "", $data); // remove pesky null-terminating bytes
}

// Split the information into easily-accessible arrays
$data_array = explode("&", $data);
$data_length = count($data_array);
for($i = 0; $i < $data_length; $i++) {
   $data_array[$i] = explode("=", $data_array[$i]); // split indexes into two arrays when = operator is present
}

function makeImage($addr,$port,$data_array,$servername){

   function validvar($var){
      if(!isset($var)){
         return false;
      }
      if($var == null){
         return false;
      }
      if($var == ""){
         return false;
      }
      return true;
   }
   $fontsmall = 4;
   $fontbig = 5;
   $heightnorm = imagefontheight($fontsmall) ;
   $heightbig = imagefontheight($fontbig) ;

   function getTop($fontsize, $heightnorm, $heightbig, $printedsmall, $printedbig){
      return 10 + $printedsmall*$heightnorm + $printedbig*$heightbig + imagefontheight($fontsize);
   }

   $printhost = 1;
   $printplayers = 1;
   $printmode = 1;
   $printurl = 1;
   $printhiddenmsg = 1;

   $version = $data_array[0][1];
   $mode = $data_array[1][1];
   $respawn = $data_array[2][1];
   $entering = $data_array[3][1];
   $voting = $data_array[4][1];
   $ai = $data_array[5][1];
   $host = $data_array[6][1];
   if($servername == "/tg/ Station 13") {
      $host = "Scardedofshadows";
   }
   $players = $data_array[7][1];

   $image = imagecreatetruecolor( 480,120 );

   $textColor = imagecolorallocate ($image, 0x93, 0xd1, 0xff);
   $textColorReserve = imagecolorallocate ($image, 0xff, 0xff, 0xff);
   $textColorRed = imagecolorallocate ($image, 0xff, 0x00, 0x00);
   $textColorURL = imagecolorallocate ($image, 0xCF, 0xCF, 0x0CF);

   if(file_exists("bg.png")){
      $image = imagecreatefrompng ( "bg.png" );
   }else{
      $textColor = $textColorReserve;
      $string = "XXX XXX X XXX";
      imagestring ($image, 5, 310, 10,  $string, $textColor);
      $string = "X   X   X   X";
      imagestring ($image, 5, 310, 22,  $string, $textColor);
      $string = "XXX XXX X XXX";
      imagestring ($image, 5, 310, 34,  $string, $textColor);
      $string = "  X   X X   X";
      imagestring ($image, 5, 310, 46,  $string, $textColor);
      $string = "XXX XXX X XXX";
      imagestring ($image, 5, 310, 58,  $string, $textColor);
      $string = " X XXX XXX  X";
      imagestring ($image, 1, 335, 82,  $string, $textColor);
      $string = " X  X  X    X";
      imagestring ($image, 1, 335, 90,  $string, $textColor);
      $string = "X   X  X X X ";
      imagestring ($image, 1, 335, 98,  $string, $textColor);
      $string = "X   X  XXX X ";
      imagestring ($image, 1, 335, 106,  $string, $textColor);
   }

   $printedsmall = 0;
   $printedbig = 0;

   if( validvar($addr) && validvar($port)){
      if(validvar($host) && validvar($players) && validvar($mode)){
         if(validvar($servername)){
            $string = "$servername";
            imagestring ($image, $fontbig, 40, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColor);
            $printedsmall++;
         }
         if($printurl){
            $string = "byond://$addr:$port";
            imagestring ($image, 2, 6, 103,  $string, $textColorURL);
         }
         if($printplayers && $printmode){
            $string = "$players players playing \"$mode\"";
            imagestring ($image, $fontsmall, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColor);
            $printedsmall++;
         }else if($printplayers){
            $string = "$players players";
            imagestring ($image, $fontbig, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColor);
            $printedsmall++;
         }else if($printmode){
            $string = "Game mode: $mode";
            imagestring ($image, $fontbig, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColor);
            $printedsmall++;
         }
         if($printhost){
            $string = "Hosted by $host";
            imagestring ($image, $fontsmall, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColor);
            $printedsmall++;
         }
      }else{
         $string = "Server unresponsive!";
         imagestring ($image, $fontbig, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColorRed);
         $printedbig++;
         $string = "byond://$addr:$port";
         imagestring ($image, 2, 6, 103,  $string, $textColorURL);
         $printedsmall++;
      }
   }else{
      $string = "Invalid server address/port.";
      imagestring ($image, $fontbig, 10, getTop($fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig),  $string, $textColorRed);
      $printedbig++;
   }

   imagepng($image,"output.png");
   imagedestroy($image);
}

/* Finally, make the image and print it to the browser */
makeImage($addr,$port,$data_array,$servername);

print "<a href = \"byond://$addr:$port\"><img src = 'output.png'></a>"


/* === Returned packet format: ===

All indexes have two arrays (one may be missing if information is not there). The second array, or index 1, is the content. Index 0 is the identifier, which is not really important.

$data_array[index][1] = content 

Useful information:

[0][1] : SS13 version               (servers based on our code read "/tg/Station13")
[1][1] : Game mode                  (example: "secret")
[2][1] : Respawn on/off             (1/0)
[3][1] : Entering allowed/disallowed   (1/0)
[4][1] : Voting allowed/disallowed     (1/0)
[5][1] : AI turned on/off           (1/0, clarification: admins can toggle this)
[6][1] : Game host                  (usually "Guest-#" or something for /tg/ station)
[7][1] : Number of players          (example: "51", note it's not an actual integer)

[8][1] : Keyname of player #0       (example: "Doohl", using mob.key, not ckey)
[9][1] : Keyname of player #1...
...
[length-1][1] : Keyname of player #playertotal - 1


tl;dr: doohls too lazy to format stats in JSON or XML
 */

?>
