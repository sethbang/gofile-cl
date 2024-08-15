# Bash Scripts Collection

This collection contains four bash scripts designed to help with file management, archiving, and obfuscation tasks. Below is an overview of each script and instructions on how to use them.

## Scripts

- [Bash Scripts Collection](#bash-scripts-collection)
  - [Scripts](#scripts)
    - [archive\_split.sh](#archive_splitsh)
    - [archive\_restore.sh](#archive_restoresh)
    - [obfuscate.sh](#obfuscatesh)
    - [restore.sh](#restoresh)
  - [Notes](#notes)

### archive_split.sh

This script creates a compressed tar archive of a directory and splits it into smaller parts.

**Usage:**
```bash
./archive_split.sh [-s split_size] /path/to/directory
```

**Options:**
- `-s split_size`: Specify the size of each split part (default: 5G)

**Example:**
```bash
./archive_split.sh -s 2G /home/user/documents
```

### archive_restore.sh

This script reassembles split archive parts and extracts the contents.

**Usage:**
```bash
./archive_restore.sh /path/to/split/files
```

**Example:**
```bash
./archive_restore.sh /home/user/backup
```

### obfuscate.sh

This script renames files in a directory with generic names and creates a mapping file.

**Usage:**
```bash
./obfuscate.sh [-d directory] [-m mapping_file]
```

**Options:**
- `-d directory`: Specify the directory to obfuscate (default: current directory)
- `-m mapping_file`: Specify the name of the mapping file (default: file_map.obf)

**Example:**
```bash
./obfuscate.sh -d /home/user/sensitive_data -m my_mapping.obf
```

### restore.sh

This script restores original file names using the mapping file created by obfuscate.sh.

**Usage:**
```bash
./restore.sh [-d directory] [-m mapping_file]
```

**Options:**
- `-d directory`: Specify the directory containing obfuscated files (default: current directory)
- `-m mapping_file`: Specify the name of the mapping file (default: file_map.obf)

**Example:**
```bash
./restore.sh -d /home/user/obfuscated_data -m my_mapping.obf
```

## Notes

- Ensure that all scripts have execute permissions before running them (`chmod +x script_name.sh`).
- Be cautious when using these scripts, especially the obfuscation and restoration scripts, as they modify file names.
- Always keep backups of important data before using these scripts.
- The archive split and restore scripts are particularly useful for handling large directories or when working with limited storage space.