<?php

require_once( 'Byond.php' );
require_once( 'PngGenerator.php' );

// Image Settings
$image_filename   = 'output.png';      // The default of PngGenerator
$background_image = 'bg.png';          // The default of PngGenerator.  If you want to set this, you must set $image_filename
$servername = "My Daedalus Server";    // Appears on the PNG image as the name of your server.
$max_image_age = 120;                  // Images less than this many seconds old are cached.
// Connection Sertings
$addr = "daedalus.example.com";
$port = 12345;

/* Finally, make the image and print it to the browser */

// print "<a href = \"byond://$addr:$port\"><img src = 'output.png'></a>"
header( "Content-type: image/png" );

if( !file_exists( $image_filename ) || ( time() - filemtime( $image_filename ) >= $max_image_age ) ) {
   $server = new Byond;
   $server->configure( $addr, $port );
   $info = $server->getInfo( '?status' );
   // Account for old BYOND SS13 servers that always return null hosts
   if( empty( $info['Host'] ) ) {
      $info['Host'] = 'Unknown';
   }
   makeImage( $addr, $port, $info, $servername, $image_filename, $background_image );
} else {
   $image = imagecreatefrompng( $image_filename );
   imagepng( $image );
   imagedestroy( $image );
}

?>
