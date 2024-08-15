#!/bin/bash

# Default split size (5GB)
split_size="5G"

# Parse optional flags
while getopts "s:" flag; do
    case "${flag}" in
        s) split_size=${OPTARG} ;;
        *) echo "Usage: $0 [-s split_size] /path/to/directory"; exit 1 ;;
    esac
done

# Shift the arguments to get the directory path
shift $((OPTIND - 1))

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Error: No directory provided."
    echo "Usage: $0 [-s split_size] /path/to/directory"
    exit 1
fi

# Set the directory path
directory=$1

# Get the base name of the directory for naming the archive
base_name=$(basename "$directory")

# Create a compressed tar archive and split it
tar -cvf - "$directory" | gzip | split -b "$split_size" - "${base_name}_part_"

echo "Archive and split completed. Files are named ${base_name}_part_aa, ${base_name}_part_ab, ..."

exit 0