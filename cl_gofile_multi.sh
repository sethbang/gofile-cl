#!/bin/bash

# Function to create or update the config file
update_config() {
    local token="$1"
    echo "auth_token=\"$token\"" > "$config_file"
    chmod 600 "$config_file"
    echo "Auth token updated in $config_file"
}

# Config file location
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    config_file="$USERPROFILE/.gofile_config"
else
    config_file="$HOME/.gofile_config"
fi

# Initialize auth_token
auth_token=""

# Check if config file exists, if so, source it
if [ -f "$config_file" ]; then
    source "$config_file"
fi

# Set other default values
default_directory="./"
default_folderid=""
recursive=false
os_type=""
min_size=""
delete_after_upload=false
move_after_upload=false

# Parse command-line arguments
while getopts ":d:a:f:ro:u:s:Dm" opt; do
  case $opt in
    d) directory="$OPTARG"
    ;;
    a) auth_token="$OPTARG"
    ;;
    f) folderid="$OPTARG"
    ;;
    r) recursive=true
    ;;
    o) os_type="$OPTARG"
    ;;
    u) echo "Please enter your new GoFile auth token:"
       read -r new_token
       update_config "$new_token"
       exit 0
    ;;
    s) min_size="$OPTARG"
    ;;
    D) delete_after_upload=true
    ;;
    m) move_after_upload=true
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        echo "Usage: $0 [-d directory] [-a auth_token] [-f folderid] [-r] [-o os_type] [-u] [-s min_size] [-D] [-m]"
        exit 1
    ;;
  esac
done

# Use defaults if not provided
directory="${directory:-$default_directory}"
folderid="${folderid:-$default_folderid}"

# Check if auth_token is set, if not, exit with an error
if [ -z "$auth_token" ]; then
    echo "Error: No auth token provided. Please set it in the config file or use the -a flag."
    exit 1
fi

# Confirmation for delete option
if [ "$delete_after_upload" = true ]; then
    echo "WARNING: The delete option (-D) will permanently remove files after successful upload."
    echo "To confirm, please type exactly: 'I understand and accept the risk of deleting files'"
    read -r confirmation
    if [ "$confirmation" != "I understand and accept the risk of deleting files" ]; then
        echo "Confirmation failed. Exiting without deleting files."
        exit 1
    fi
fi

# Confirmation for move option
if [ "$move_after_upload" = true ]; then
    echo "The move option (-m) will move files to a 'completed' folder after successful upload."
    echo "To confirm, please type exactly: 'I understand and accept the file movement'"
    read -r confirmation
    if [ "$confirmation" != "I understand and accept the file movement" ]; then
        echo "Confirmation failed. Exiting without moving files."
        exit 1
    fi
    # Create 'completed' folder if it doesn't exist
    mkdir -p "${directory}/completed"
fi

# Detect OS if not specified
if [ -z "$os_type" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        os_type="windows"
    else
        echo "Unsupported OS. Please specify using -o option (macos, linux, or windows)."
        exit 1
    fi
fi

# Function to get available 'na' server
get_na_server() {
    local max_attempts=5
    local attempt=1
    local server_info
    local na_server

    while [ $attempt -le $max_attempts ]; do
        server_info=$(curl -s -X GET 'https://api.gofile.io/servers')
        if [ $? -ne 0 ]; then
            echo "Failed to fetch server info. Retrying in 60 seconds (attempt $attempt of $max_attempts)..." >&2
            echo "You can force quit the script with Ctrl+C if needed." >&2
            sleep 60
            ((attempt++))
            continue
        fi

        na_server=$(echo "$server_info" | jq -r '.data.servers[] | select(.zone == "na") | .name' | head -n 1)
        if [ -n "$na_server" ]; then
            echo "$na_server"
            return 0
        fi

        echo "No 'na' server available. Retrying in 60 seconds (attempt $attempt of $max_attempts)..." >&2
        echo "You can force quit the script with Ctrl+C if needed." >&2
        sleep 60
        ((attempt++))
    done

    echo "Failed to get an 'na' server after $max_attempts attempts. Exiting." >&2
    exit 1
}

# Function to format time
format_time() {
    local seconds=$1
    printf "%02d:%02d:%02d" $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))
}

# Function to format file size
format_size() {
    local size=$1
    if [ $size -ge 1073741824 ]; then
        printf "%.2f GB" $(awk "BEGIN {printf \"%.2f\", $size/1073741824}")
    elif [ $size -ge 1048576 ]; then
        printf "%.2f MB" $(awk "BEGIN {printf \"%.2f\", $size/1048576}")
    else
        printf "%d bytes" $size
    fi
}

# Function to convert size to bytes
convert_to_bytes() {
    local size="$1"
    local unit="${size: -2}"
    local value="${size%??}"

    case "$unit" in
        KB|kb) echo $((value * 1024)) ;;
        MB|mb) echo $((value * 1024 * 1024)) ;;
        *) echo "$size" ;;
    esac
}

# Set find options based on recursive flag, OS, and min_size
if [ -n "$min_size" ]; then
    min_size_bytes=$(convert_to_bytes "$min_size")
    size_option="-size +${min_size_bytes}c"
else
    size_option=""
fi

if [ "$recursive" = true ]; then
    find_opts="-type f $size_option ! -name '.*' ! -name 'SYNOINDEX_*'"
else
    find_opts="-maxdepth 1 -type f $size_option ! -name '.*' ! -name 'SYNOINDEX_*'"
fi

# Get total number of files and size
if [ "$os_type" = "macos" ]; then
    total_files=$(eval find "$directory" $find_opts | wc -l)
    total_size=$(eval find "$directory" $find_opts -print0 | xargs -0 stat -f%z | awk '{sum+=$1} END {print sum}')
else
    total_files=$(eval find "$directory" $find_opts | wc -l)
    total_size=$(eval find "$directory" $find_opts -print0 | xargs -0 stat -c%s | awk '{sum+=$1} END {print sum}')
fi

# Initialize counters
current_file=0
uploaded_size=0

# Create a temporary file to store sorted file list
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Sort files by size and save to temporary file
if [ "$os_type" = "macos" ]; then
    eval find "$directory" $find_opts -print0 | while IFS= read -r -d '' file; do
      file_size=$(stat -f%z "$file")
      echo "$file_size $file"
    done | sort -n | cut -d' ' -f2- > "$temp_file"
else
    eval find "$directory" $find_opts -print0 | while IFS= read -r -d '' file; do
      file_size=$(stat -c%s "$file")
      echo "$file_size $file"
    done | sort -n | cut -d' ' -f2- > "$temp_file"
fi

# Read from the temporary file and process each file
while read -r file; do
  if [ -f "$file" ]; then
    ((current_file++))
    file_name=$(basename "$file")
    if [ "$os_type" = "macos" ]; then
        file_size=$(stat -f%z "$file")
    else
        file_size=$(stat -c%s "$file")
    fi
    
    formatted_size=$(format_size $file_size)
    echo "=========================================="
    echo "Uploading file $current_file of $total_files: $file_name ($formatted_size)"
    echo "Overall progress: $((uploaded_size * 100 / total_size))% completed"
    
    # Get the 'na' server for this upload
    storenum=$(get_na_server)
    echo "Using server: $storenum"
    
    # GoFile API endpoint
    url="https://$storenum.gofile.io/contents/uploadfile"
    
    start_time=$(date +%s)
    
    curl_output=$(curl -X POST "$url" \
         -H "Authorization: Bearer $auth_token" \
         -F "file=@$file" \
         -F "folderId=$folderid" \
         --progress-bar)
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    uploaded_size=$((uploaded_size + file_size))
    
    upload_status=$(echo "$curl_output" | jq -r '.status')
    download_page=$(echo "$curl_output" | jq -r '.data.downloadPage')
    
    echo
    if [ "$upload_status" == "ok" ]; then
      echo "Uploaded $file_name successfully!"
      echo "Time taken: $(format_time $duration)"
      echo "Download Page: $download_page"
      
      if [ "$delete_after_upload" = true ]; then
        rm "$file"
        echo "File deleted: $file_name"
      elif [ "$move_after_upload" = true ]; then
        mv "$file" "${directory}/completed/"
        echo "File moved to completed folder: $file_name"
      fi
    else
      echo "Failed to upload $file_name"
      echo "Error: $curl_output"
    fi
    
    echo "Overall progress: $((uploaded_size * 100 / total_size))% completed"
    echo "=========================================="
    echo
  fi
done < "$temp_file"

total_formatted_size=$(format_size $total_size)
echo "All files uploaded. Total size: $total_formatted_size. Total time: $(format_time $SECONDS)"