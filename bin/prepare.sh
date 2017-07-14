#!/bin/bash

if [ -z ${1+x} ]; then echo "No path was provided."; exit 1; else srcfilein=$1; fi
if [ -z ${2+x} ]; then echo "No destination was provided."; exit 1; else dest=$2; fi

function sameimg(){
    if [ -z ${1+x} ]; then echo "No file 1 was provided."; exit 1; else file1=$1; fi
    # echo $file1
    if [ -z ${2+x} ]; then echo "No file 2 was provided."; exit 1; else file2=$2; fi
    # echo $file2

    compareresult=$(compare -metric RMSE "$file1" "$file2" :/dev/null 2>&1)

    if [ "$compareresult" == "0 (0)" ]; then
	return 0
    fi
    return 1
}

srcfile=$(realpath $srcfilein)
srcname=$(basename $srcfile)
srcext=".${srcname##*.}"
srcname="${srcname%.*}"
srcdir=$(dirname $srcfile)

if [ "$srcext" == ".svg" ]; then
    if [ -f "$dest/$srcname[Source].png" ]; then
        rm "$dest/$srcname[Source].png"
    fi
    inkscape --export-png "$dest/$srcname[Source].png" -w 512 "$srcdir/$srcname.svg" > /dev/null 2>&1
elif [ "$srcext" == ".webp" ]; then
    if [ -f "$dest/$srcname[Source].png" ]; then
        rm "$dest/$srcname[Source].png"
    fi

    convert "$srcdir/$srcname.webp" -background transparent -gravity center -resize 310x310 -extent 310x310 "PNG32:$dest/$srcname[Source].png"
else
    cp "$srcdir/$srcname.png" "$dest/$srcname[Source].png"
fi

##########

filedir=$dest
filename=$srcname
namemod="\[Source\]"

##########

convert "$filedir/$filename$namemod.png" -trim "PNG32:$filedir/$filename[Magick].png"

if sameimg "$filedir/$filename$namemod.png" "$filedir/$filename[Magick].png"; then
    rm "$filedir/$filename[Magick].png"
else
    namemod="\[Magick\]"
fi

width=$(identify -format '%w' "$filedir/$filename$namemod.png")
height=$(identify -format '%h' "$filedir/$filename$namemod.png")
size=$(($width>$height?$width:$height))

if [ $height -eq $width ]; then
    # echo "Already square"
    squaremod=$namemod
else
    # echo "Not square"
    squaremod="[Square]"
    dimensions=$size"x"$size
    convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize $dimensions -extent $dimensions "PNG32:$filedir/$filename$squaremod.png"
fi

if [ $size -gt 70 ]; then
    convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 70x70 -extent 70x70 "PNG32:$filedir/$filename[Small].png"
    if [ $size -gt 150 ]; then
        convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 150x150 -extent 150x150 "PNG32:$filedir/$filename[Medium].png"
        convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 310x150 -extent 310x150 "PNG32:$filedir/$filename[Wide].png"
        if [ $size -gt 310 ]; then
            convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 310x310 -extent 310x310 "PNG32:$filedir/$filename[Large].png"
            convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 310 -extent 310x150 "PNG32:$filedir/$filename[Wide2].png"

            if sameimg "$filedir/$filename[Wide].png" "$filedir/$filename[Wide2].png"; then
		rm "$filedir/$filename[Wide2].png"
	    fi
        else
            convert "$filedir/$filename$namemod.png" -background transparent -gravity center -extent 310x310 "PNG32:$filedir/$filename[Large].png"
        fi
    else
        convert "$filedir/$filename$namemod.png" -background transparent -gravity center -extent 150x150 "PNG32:$filedir/$filename[Medium].png"
    fi
else
    convert "$filedir/$filename$namemod.png" -background transparent -gravity center -extent 70x70 "PNG32:$filedir/$filename[Small].png"
fi

#convert "$filedir/$filename$namemod.png" -background transparent -gravity center -resize 256x256  -extent 256x256 "PNG32:$filedir/$filename[Icon256].png"
#convert "$filedir/$filename[Icon256].png" -define icon:auto-resize=256,192,128,96,64,48,32,24,16 "$filedir/$filename.ico"
#rm "$filedir/$filename[Icon256].png"

exit 0
