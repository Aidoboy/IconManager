#!/bin/bash

dir=$(realpath $(realpath "$0" | sed 's|\(.*\)/.*|\1|')/../)

$dir/bin/clean.sh

for folder in $(find $dir/input -type d); do
    new=$(echo $folder | sed -e 's/\(.*\)input/\1output/g')
    if [ ! -d "$new" ]; then
	mkdir $new
    fi
done

for img in $(find "$dir/input" -name '*.png'); do
    dest=$(realpath "$img" | sed 's|\(.*\)/.*|\1|' | sed -e 's/\(.*\)input/\1output/g')/
    $dir/bin/prepare.sh $img $dest
done

for img in $(find "$dir/input" -name '*.svg' -or -name '*.webp'); do
    dest=$(realpath "$img" | sed 's|\(.*\)/.*|\1|' | sed -e 's/\(.*\)input/\1output/g')
    $dir/bin/prepare.sh $img $dest
done
