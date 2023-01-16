convert ../assets/rock2.png -trim -scale 32x32! -colors 16 -depth 4 rock2.png
X16PngConverter rock2.png -sprites -h 32 -w 32 -t $ff000000 -p bin
del rock2.png

convert ../assets/rock2.png -trim -scale 16x16! -colors 16 -depth 4 rock3.png
X16PngConverter rock3.png -sprites -h 16 -w 16 -t $ff000000 -p bin
del rock3.png

convert ../assets/rock2.png -trim -scale 8x8! -colors 16 -depth 4 rock4.png
X16PngConverter rock4.png -sprites -h 8 -w 8 -t $ff000000 -p bin
del rock4.png

convert ../assets/pshot.png -trim -scale 8x8! -colors 16 -depth 4 pshot.png
X16PngConverter pshot.png -sprites -h 8 -w 8 -t $ff000000 -p bin
del pshot.png

convert ../assets/ship.png -trim -scale 16x16! ship0.png
convert ship0.png +append ship.png

convert -background #000000 -rotate  22.5 ../assets/ship.png ship1.png
convert ship1.png -trim -scale 16x16! ship1.png

convert -background #000000 -rotate  45 ../assets/ship.png ship2.png
convert ship2.png -trim -scale 16x16! ship2.png

convert -background #000000 -rotate  67.5 ../assets/ship.png ship3.png
convert ship3.png -trim -scale 16x16! ship3.png

convert -background #000000 -rotate  90 ../assets/ship.png ship4.png
convert ship4.png -trim -scale 16x16! ship4.png

convert -background #000000 -rotate  112.5 ../assets/ship.png ship5.png
convert ship5.png -trim -scale 16x16! ship5.png

convert -background #000000 -rotate  135 ../assets/ship.png ship6.png
convert ship6.png -trim -scale 16x16! ship6.png

convert -background #000000 -rotate  157.5 ../assets/ship.png ship7.png
convert ship7.png -trim -scale 16x16! ship7.png

convert -background #000000 -rotate  180 ../assets/ship.png ship8.png
convert ship8.png -trim -scale 16x16! ship8.png

convert -background #000000 -rotate  202.5 ../assets/ship.png ship9.png
convert ship9.png -trim -scale 16x16! ship9.png

convert -background #000000 -rotate  225 ../assets/ship.png ship10.png
convert ship10.png -trim -scale 16x16! ship10.png

convert -background #000000 -rotate  247.5 ../assets/ship.png ship11.png
convert ship11.png -trim -scale 16x16! ship11.png

convert -background #000000 -rotate  270 ../assets/ship.png ship12.png
convert ship12.png -trim -scale 16x16! ship12.png

convert -background #000000 -rotate  292.5 ../assets/ship.png ship13.png
convert ship13.png -trim -scale 16x16! ship13.png

convert -background #000000 -rotate  315 ../assets/ship.png ship14.png
convert ship14.png -trim -scale 16x16! ship14.png

convert -background #000000 -rotate  337.5 ../assets/ship.png ship15.png
convert ship15.png -trim -scale 16x16! ship15.png

convert ship8.png ship7.png ship6.png ship5.png ship4.png ship3.png ship2.png ship1.png ship0.png ship15.png ship14.png ship13.png ship12.png ship11.png ship10.png ship9.png +append ship.png
convert ship.png -colors 16 -depth 4 ship.png
X16PngConverter ship.png -sprites -h 16 -w 16 -t $ff000000 -p bin
del ship*.png
