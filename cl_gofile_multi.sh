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

# Parse command-line arguments
while getopts ":d:a:f:ro:u" opt; do
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
    \?) echo "Invalid option -$OPTARG" >&2
        echo "Usage: $0 [-d directory] [-a auth_token] [-f folderid] [-r] [-o os_type] [-u]"
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
    local server_info=$(curl -s -X GET 'https://api.gofile.io/servers')
    local na_server=$(echo "$server_info" | jq -r '.data.servers[] | select(.zone == "na") | .name' | head -n 1)
    if [ -z "$na_server" ]; then
        echo "No 'na' server available. Exiting." >&2
        exit 1
    fi
    echo "$na_server"
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
        printf "%.2f GB" $(echo "scale=2; $size/1073741824" | bc)
    elif [ $size -ge 1048576 ]; then
        printf "%.2f MB" $(echo "scale=2; $size/1048576" | bc)
    else
        printf "%d bytes" $size
    fi
}

# Set find options based on recursive flag and OS
if [ "$recursive" = true ]; then
    if [ "$os_type" = "windows" ]; then
        find_opts="-type f -size +1M ! -name '.*' ! -name 'SYNOINDEX_*'"
    else
        find_opts="-type f -size +1M ! -name '.*' ! -name 'SYNOINDEX_*'"
    fi
else
    if [ "$os_type" = "windows" ]; then
        find_opts="-maxdepth 1 -type f -size +1M ! -name '.*' ! -name 'SYNOINDEX_*'"
    else
        find_opts="-maxdepth 1 -type f -size +1M ! -name '.*' ! -name 'SYNOINDEX_*'"
    fi
fi

# Get total number of files and size
if [ "$os_type" = "macos" ]; then
    total_files=$(eval find "$directory" $find_opts | wc -l)
    total_size=$(eval find "$directory" $find_opts -print0 | xargs -0 stat -f%z | awk '{sum+=$1} END {print sum}')
elif [ "$os_type" = "linux" ]; then
    total_files=$(eval find "$directory" $find_opts | wc -l)
    total_size=$(eval find "$directory" $find_opts -print0 | xargs -0 stat -c%s | awk '{sum+=$1} END {print sum}')
elif [ "$os_type" = "windows" ]; then
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
elif [ "$os_type" = "linux" ]; then
    eval find "$directory" $find_opts -print0 | while IFS= read -r -d '' file; do
      file_size=$(stat -c%s "$file")
      echo "$file_size $file"
    done | sort -n | cut -d' ' -f2- > "$temp_file"
elif [ "$os_type" = "windows" ]; then
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
    elif [ "$os_type" = "linux" ]; then
        file_size=$(stat -c%s "$file")
    elif [ "$os_type" = "windows" ]; then
        file_size=$(stat -c%s "$file")
    fi
    
    formatted_size=$(format_size $file_size)
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
    file_id=$(echo "$curl_output" | jq -r '.data.fileId')
    
    if [ "$upload_status" == "ok" ]; then
      echo -e "\nUploaded $file_name successfully!"
      echo "Time taken: $(format_time $duration)"
      echo "Download Page: $download_page"
      echo "File ID: $file_id"
    else
      echo -e "\nFailed to upload $file_name"
      echo "Error: $curl_output"
    fi
    
    echo "Overall progress: $((uploaded_size * 100 / total_size))% completed"
    echo "----------------------------------------"
  fi
done < "$temp_file"

total_formatted_size=$(format_size $total_size)
echo "All files uploaded. Total size: $total_formatted_size. Total time: $(format_time $SECONDS)"