

# GoFile Uploader

This repository contains a bash script and an HTML file for uploading files to GoFile, a free file sharing and storage service.

## Contents

1. `cl_gofile_multi.sh`: A Bash script for uploading multiple files to GoFile.
2. `index.html`: An HTML file for generating commands to use with the Bash script.

## cl_gofile_multi.sh

This Bash script allows you to upload multiple files to GoFile with various options.

### Features

- Upload multiple files to GoFile
- Recursive directory scanning
- Custom folder ID support
- Progress tracking
- OS detection (macOS, Linux, Windows)
- Authentication token management

### Prerequisites

- Bash shell
- `curl`
- `jq` (for JSON parsing)

### Usage

```bash
./cl_gofile_multi.sh [-d directory] [-a auth_token] [-f folderid] [-r] [-o os_type] [-u]
```

#### Options:

- `-d`: Specify the directory containing files to upload (default: "./")
- `-a`: Provide the GoFile authentication token
- `-f`: Specify the GoFile folder ID to upload to
- `-r`: Enable recursive directory scanning
- `-o`: Manually set the OS type (macos, linux, or windows)
- `-u`: Update the stored authentication token

### Examples

1. Upload files from the current directory:
   ```bash
   ./cl_gofile_multi.sh -a "your_auth_token"
   ```

2. Upload files recursively from a specific directory:
   ```bash
   ./cl_gofile_multi.sh -d "/path/to/directory" -a "your_auth_token" -r
   ```

3. Upload files to a specific GoFile folder:
   ```bash
   ./cl_gofile_multi.sh -a "your_auth_token" -f "gofile_folder_id"
   ```

4. Update the stored authentication token:
   ```bash
   ./cl_gofile_multi.sh -u
   ```

## index.html

This HTML file provides a user-friendly interface for generating commands to use with the `cl_gofile_multi.sh` script.

### Features

- Input fields for directory, authentication token, and folder ID
- Toggle switches for recursive uploads and authentication token usage
- OS type selection
- Command generation based on user input

### Usage

1. Open `index.html` in a web browser.
2. Fill in the desired options:
   - Directory: The path to the files you want to upload
   - Auth Token: Your GoFile authentication token
   - Folder ID: The ID of the GoFile folder to upload to
   - Recursive: Toggle on to include subdirectories
   - OS Type: Select your operating system or leave as auto-detect
3. Click "Generate Command" to create the appropriate command for `cl_gofile_multi.sh`.
4. Copy the generated command and run it in your terminal.

## Configuration

The script stores the authentication token in a configuration file:

- On Unix-like systems (macOS, Linux): `$HOME/.gofile_config`
- On Windows: `%USERPROFILE%\.gofile_config`

You can update this token using the `-u` option or by manually editing the file.

## Security Note

Keep your GoFile authentication token secure. Do not share it or commit it to public repositories.

## Limitations

- The script requires files to be larger than 1MB for upload.
- It excludes hidden files and files named 'SYNOINDEX_*'.

## Contributing

Contributions to improve the script or HTML interface are welcome. Please submit pull requests or open issues for any bugs or feature requests.

## License

This project is open-source. Please include an appropriate license file in your repository and specify the license terms here.