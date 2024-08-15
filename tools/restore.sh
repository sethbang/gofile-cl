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

# Check if the mapping file exists
if [ ! -e "$MAPPING_FILE" ]; then
  echo "Mapping file $MAPPING_FILE not found. Aborting."
  exit 1
fi

# Read the mapping file and restore original names
while IFS=" " read -r original arrow new; do
  # Remove any leading or trailing whitespace from the variables
  original=$(echo "$original" | xargs)
  new=$(echo "$new" | xargs)

  # Check that the line is correctly parsed
  if [[ "$arrow" == "->" ]]; then
    # Extract just the filename from the original path
    original_name=$(basename "$original")

    # Rename the obfuscated file back to its original name
    mv "$DIRECTORY/$new" "$DIRECTORY/$original_name"
  else
    echo "Skipping invalid line: $original $arrow $new"
  fi
done < "$MAPPING_FILE"

echo "Restoration complete."