#!/bin/sh

# Set trash directory path
TRASH_DIR=~/.local/share/Trash/files

# Check if SQLite is installed, if not install it
if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "SQLite is not installed, installing now..."
    sudo apt-get update
    sudo apt-get install sqlite3
fi

# Check if the deleted_files table exists, if not create it
if ! sqlite3 ~/.local/share/Trash/trash.db "SELECT name FROM sqlite_master WHERE type='table' AND name='deleted_files';" | grep -q "deleted_files"; then
    echo "Creating deleted_files table..."
    sqlite3 ~/.local/share/Trash/trash.db "CREATE TABLE deleted_files (id INTEGER PRIMARY KEY, file_path TEXT, delete_time TEXT, deleted_by TEXT);"
fi

# Move file to trash directory
# Check if trash directory exists, if not create it
if [ ! -d "$TRASH_DIR" ]; then
    mkdir -p "$TRASH_DIR"
fi

clear_trash() {
    rm -rf "$TRASH_DIR"/*
}

list_trash() {
    # Retrieve the deleted files' metadata from the deleted_files table
    deleted_files=$(sqlite3 ~/.local/share/Trash/trash.db "SELECT file_path, delete_time, deleted_by FROM deleted_files;")

    # Print the deleted files' metadata in a formatted table
    printf "%-50s %-20s %-20s\n" "FILE NAME" "DELETE TIME" "DELETED BY"
    printf "%-50s %-20s %-20s\n" "---------" "-----------" "----------"
    echo "$deleted_files" | while read -r file_path delete_time deleted_by; do
        file_name=$(basename "$file_path")
        printf "%-50s %-20s %-20s\n" "$file_name" "$(date -d @$delete_time +%Y-%m-%d_%H:%M:%S)" "$deleted_by"
    done
}
restore_file() {
    if [ $# -eq 0 ]; then
        echo "Error: No files specified for restore."
        exit 1
    fi
    for file_name in "$@"; do
        file_path="$TRASH_DIR/$file_name"
        if [ ! -f "$file_path" ]; then
            echo "Error: File not found in trash directory: $file_name"
            continue
        fi
        delete_time=$(echo "$file_name" | awk '{print $1}')
        new_file_name=$(echo "$file_name" | awk '{print $2}')
        mv "$file_path" "$(date -d @$delete_time +%Y-%m-%d_%H-%M-%S)_$new_file_name"
    done
}

show_help() {
    echo "Usage: trash [OPTIONS] [FILE]..."
    echo "Move files to trash directory and restore them if needed."
    echo ""
    echo "Options:"
    echo "  -c, --clear     Clear the trash directory."
    echo "  -l, --ls        List files in the trash directory."
    echo "  -r, --restore   Restore a file from the trash directory."
    echo "  -h, --help      Show this help message and exit."
}

while getopts "clr:h" opt; do
    case $opt in
    c)
        clear_trash
        exit 0
        ;;
    l)
        list_trash
        exit 0
        ;;
    r)
        shift $((OPTIND - 1))
        restore_file "$@"
        exit 0
        ;;
    h)
        show_help
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

# Move files to trash directory
for file in "$@"; do

    # Get the absolute path of the file
    file_path=$(realpath "$file")

    # Move the file to the trash directory
    delete_time=$(date +%s)
    file_name=$(basename "$file_path")
    md5_name=$(echo -n "$file_name$delete_time" | md5sum | awk '{print $1}')
    mv "$file_path" "$TRASH_DIR/$md5_name"

    # Insert a new row into the deleted_files table
    deleted_by=$(whoami)
    sqlite3 ~/.local/share/Trash/trash.db "INSERT INTO deleted_files (file_path, delete_time, deleted_by) VALUES ('$file_path', '$delete_time', '$deleted_by');"

done
