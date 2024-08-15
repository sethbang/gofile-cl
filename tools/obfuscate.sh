#!/bin/bash

# Default values
DIRECTORY="."
MAPPING_FILE="file_map.obf"

# Parse flags
while getopts "d:m:" opt; do
  case "$opt" in
    d) DIRECTORY="$OPTARG" ;;
    m) MAPPING_FILE="$OPTARG" ;;
    *) echo "Usage: $0 [-d directory] [-m mapping_file]"; exit 1 ;;
  esac
done

# Check if the mapping file already exists
if [ -e "$MAPPING_FILE" ]; then
  echo "Mapping file $MAPPING_FILE already exists. Aborting to prevent overwriting."
  exit 1
fi

# Create or truncate the mapping file
: > "$MAPPING_FILE"

# Counter for generating new file names
counter=1

# Traverse through files in the directory
for file in "$DIRECTORY"/*; do
  if [ -f "$file" ]; then
    # Generate a new file name (e.g., file_1, file_2, etc.)
    new_name=$(printf "file_%04d" "$counter")
    # Increment the counter
    counter=$((counter + 1))

    # Get the file extension
    extension="${file##*.}"

    # Combine the new name with the extension
    new_file_name="$new_name.$extension"

    # Rename the file
    mv "$file" "$DIRECTORY/$new_file_name"

    # Record the original and new name in the mapping file
    echo "$file -> $new_file_name" >> "$MAPPING_FILE"
  fi
done

echo "Obfuscation complete. Mapping saved in $MAPPING_FILE."