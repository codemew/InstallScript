#!/bin/bash

sudo apt install imagemagick -y
# Find all .png file and save them inside out.txt
find . -type f -name "*.png" > out.txt

# Loop through each line in out.txt
while IFS= read -r filename; do
    # Check if the file exists
    if [ -f "$filename" ]; then
        # Run pngcrush command for the file
        mogrify "$filename"
    else
        echo "File $filename not found."
    fi
done < out.txt
rm -f out.txt

