<?php

function makeImage( $addr, $port, $data_array, $servername, $filename='output.png', $background='bg.png' ) {

   function validvar( $var ) {
      if( ! isset( $var ) ) {
         return false;
      }
      if( $var == null ) {
         return false;
      }
      if( $var == "" ) {
         return false;
      }
      return true;
   }

   $fontsmall = 4;
   $fontbig = 5;
   $heightnorm = imagefontheight($fontsmall) ;
   $heightbig = imagefontheight($fontbig) ;

   function getTop( $fontsize, $heightnorm, $heightbig, $printedsmall, $printedbig ) {
      return 25 + $printedsmall*$heightnorm + $printedbig * $heightbig + imagefontheight( $fontsize );
   }

   $printhost = 1;
   $printplayers = 1;
   $printmode = 1;
   $printurl = 1;
   $printhiddenmsg = 1;

   $image = imagecreatetruecolor( 480, 120 );
   //
   $textColor = imagecolorallocate ( $image, 0xa3, 0xe1, 0xff );
   $textColorReserve = imagecolorallocate ( $image, 0xff, 0xff, 0xff );
   $textColorRed = imagecolorallocate ( $image, 0xff, 0x00, 0x00 );
   $textColorURL = imagecolorallocate ( $image, 0xCF, 0xCF, 0x0CF );
   //
   if( file_exists( $background ) ) {
      $image = imagecreatefrompng ( $background );
   } else {
      // Put some default background here
   }
   //
   $printedsmall = 0;
   $printedbig = 0;
   //
   if( $data_array['Status'] == 'Error' ) {
      // Generate error .png image here
      echo( 'Error handling not yet implemented' . "\n" );
      echo( "Error received: " . $data_array['Error'] . "\n" );
      die( print_r( $data_array ) );
   } else {
      $version    = $data_array['Version'];
      $mode       = $data_array['Mode'];
      $respawn    = $data_array['Respawn'];
      $entering   = $data_array['Join'];
      $voting     = $data_array['Voting'];
      $ai         = $data_array['AI'];
      $host       = $data_array['Host'];
      $players    = $data_array['NumPlayers'];
   }
   //
   if( validvar( $addr ) && validvar( $port ) ) {
      if( validvar( $host ) && validvar( $mode ) ) {
         if( validvar( $servername ) ) {
            $string = "$servername";
            imagestring ( $image, $fontbig, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig ), $string, $textColor );
            $printedsmall++;
         }
         if( $printurl ) {
            $string = "byond://$addr:$port";
            imagestring ( $image, 2, 300, 3, $string, $textColorURL );
         }
         if( $printplayers && $printmode ) {
            if( $players == 0 ) { 
               $string = "No players online";
            } else if( $players == 1 ) {
               $string = "$players player playing \"$mode\"";
            } else {
               $string = "$players players playing \"$mode\"";
            }
            imagestring( $image, $fontsmall, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig ), $string, $textColor);
            $printedsmall++;
         } else if( $printplayers ) {
            $string = "$players players";
            imagestring( $image, $fontbig, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig ), $string, $textColor);
            $printedsmall++;
         } else if( $printmode ) {
            $string = "Game mode: $mode";
            imagestring( $image, $fontbig, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig), $string, $textColor);
            $printedsmall++;
         }
         if( $printhost ) {
            $string = "Hosted by $host";
            imagestring( $image, $fontsmall, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig ), $string, $textColor);
            $printedsmall++;
         }
      } else {
         $string = "Server unresponsive!";
         imagestring( $image, $fontbig, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig ), $string, $textColorRed);
         $printedbig++;
         $string = "byond://$addr:$port";
         imagestring( $image, 2, 6, 375,  $string, $textColorURL );
         $printedsmall++;
      }
   } else {
      $string = "Invalid server address/port.";
      imagestring( $image, $fontbig, 175, getTop( $fontsmall, $heightnorm, $heightbig, $printedsmall, $printedbig), $string, $textColorRed );
      $printedbig++;
   }

   imagepng( $image, $filename );
   imagepng( $image );
   imagedestroy( $image );
}
?>
