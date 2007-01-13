<?php

list($width, $height, $type, $attr) = getimagesize("../../data/bottom.gif");
echo "1: $width, $height, $type, $attr\n";
list($width, $height, $type, $attr) = getimagesize("../../data/bottom.png");
echo "2: $width, $height, $type, $attr\n";
list($width, $height, $type, $attr) = getimagesize("../../data/bottom.jpg");
echo "3: $width, $height, $type, $attr\n";
// list($width, $height, $type, $attr) = getimagesize("http://www.google.com/logo.gif");
// echo "4: $width, $height, $type, $attr\n";


// list($width, $height, $type, $attr) = getimagesize("../../data/bottom.gif", $rest);
// echo "1: $width, $height, $type, $attr\n";
// var_dump($rest);
// list($width, $height, $type, $attr) = getimagesize("../../data/bottom.png", $rest);
// echo "2: $width, $height, $type, $attr\n";
// var_dump($rest);
// list($width, $height, $type, $attr) = getimagesize("../../data/bottom.jpg", $rest);
// echo "3: $width, $height, $type, $attr\n";
// var_dump($rest);


// list($width, $height, $type, $attr) = getimagesize("http://www.google.com/logo.gif", $rest);
// echo "4: $width, $height, $type, $attr\n";
// var_dump($rest);

echo "gif: " . image_type_to_mime_type(IMAGETYPE_GIF) . "\n";
echo "jpeg: " . image_type_to_mime_type(IMAGETYPE_JPEG) . "\n";
echo "png: " . image_type_to_mime_type(IMAGETYPE_PNG) . "\n";


echo " IMAGETYPE_GIF: " .  IMAGETYPE_GIF . " " . 
                    image_type_to_mime_type( IMAGETYPE_GIF) . "\n";
echo " IMAGETYPE_JPEG: " .  IMAGETYPE_JPEG . " " . 
                    image_type_to_mime_type( IMAGETYPE_JPEG) . "\n";
echo " IMAGETYPE_PNG: " .  IMAGETYPE_PNG . " " . 
                    image_type_to_mime_type( IMAGETYPE_PNG) . "\n";
echo " IMAGETYPE_SWF: " .  IMAGETYPE_SWF . " " . 
                    image_type_to_mime_type( IMAGETYPE_SWF) . "\n";
echo " IMAGETYPE_PSD: " .  IMAGETYPE_PSD . " " . 
                    image_type_to_mime_type( IMAGETYPE_PSD) . "\n";
echo " IMAGETYPE_BMP: " .  IMAGETYPE_BMP . " " . 
                    image_type_to_mime_type( IMAGETYPE_BMP) . "\n";
echo " IMAGETYPE_TIFF_II: " .  IMAGETYPE_TIFF_II . " " . 
                    image_type_to_mime_type( IMAGETYPE_TIFF_II) . "\n";
echo " IMAGETYPE_TIFF_MM: " .  IMAGETYPE_TIFF_MM . " " . 
                    image_type_to_mime_type( IMAGETYPE_TIFF_MM) . "\n";
echo " IMAGETYPE_JPC: " .  IMAGETYPE_JPC . " " . 
                    image_type_to_mime_type( IMAGETYPE_JPC) . "\n";
echo " IMAGETYPE_JPEG2000: " .  IMAGETYPE_JPEG2000 . " " . 
                    image_type_to_mime_type( IMAGETYPE_JPEG2000) . "\n";
echo " IMAGETYPE_JP2: " .  IMAGETYPE_JP2 . " " . 
                    image_type_to_mime_type( IMAGETYPE_JP2) . "\n";
echo " IMAGETYPE_JPX: " .  IMAGETYPE_JPX . " " . 
                    image_type_to_mime_type( IMAGETYPE_JPX) . "\n";
echo " IMAGETYPE_JB2: " .  IMAGETYPE_JB2 . " " . 
                    image_type_to_mime_type( IMAGETYPE_JB2) . "\n";
//echo " IMAGETYPE_SWC: " .  IMAGETYPE_SWC . " " . 
//                    image_type_to_mime_type( IMAGETYPE_SWC) . "\n";
echo " IMAGETYPE_IFF: " .  IMAGETYPE_IFF . " " . 
                    image_type_to_mime_type( IMAGETYPE_IFF) . "\n";
echo " IMAGETYPE_WBMP: " .  IMAGETYPE_WBMP . " " . 
                    image_type_to_mime_type( IMAGETYPE_WBMP) . "\n";
echo " IMAGETYPE_XBM: " .  IMAGETYPE_XBM . " " . 
                    image_type_to_mime_type( IMAGETYPE_XBM) . "\n";


?>