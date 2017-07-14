#!/bin/bash

dir=$(realpath $(realpath "$0" | sed 's|\(.*\)/.*|\1|')/../)

rm -r $dir/output/*

exit

# rm $dir/*[*].png
find $dir -type f -name '*\[*\].png' -delete

for file in "$dir"/*.png; do
    if [ -f "${file:0:-4}.ico" ]; then
        rm "${file:0:-4}.ico"
    fi
done

for file in "$dir"/*.svg; do
    if [ -f "${file:0:-4}.png" ]; then
        rm "${file:0:-4}.png"
    fi
done


for file in "$dir"/*.webp; do
    if [ -f "${file:0:-5}.png" ]; then
        rm "${file:0:-5}.png"
    fi
done
