#!/bin/bash

# Parse the directory containing the split files as an argument
if [ -z "$1" ]; then
    echo "Error: No directory containing split files provided."
    echo "Usage: $0 /path/to/split/files"
    exit 1
fi

# Set the directory containing the split files
split_dir=$1

# Get the base name for the reassembled archive
base_name=$(ls "$split_dir" | head -n 1 | cut -d'_' -f1)

# Navigate to the directory containing the split files
cd "$split_dir" || { echo "Failed to change directory to $split_dir"; exit 1; }

# Reassemble the split parts
cat ${base_name}_part_* > ${base_name}.tar.gz

echo "Reassembly completed. Reassembled file is ${base_name}.tar.gz."

# Extract the reassembled archive
gzip -d ${base_name}.tar.gz
tar -xvf ${base_name}.tar

echo "Extraction completed. Files have been extracted."

exit 0