#!/bin/zsh

# Get source directory from argument or use default
SOURCE_DIR="${1:-/Users/chlee/workplace/obsidian}"
DEST_DIR="$(pwd)"

# Find markdown files containing 'gh-page: true' in frontmatter
matching_files=()
while IFS= read -r line; do
  matching_files+=("$line")
done < <(grep -rl --include='*.md' '^gh-page: true' "$SOURCE_DIR")

if [[ ${#matching_files[@]} -eq 0 ]]; then
  echo "No matching files found."
  exit 1
fi

# Use fzf for file selection (multi-select enabled)
selected_files=()
while IFS= read -r line; do
  selected_files+=("$line")
done < <(printf "%s\n" "${matching_files[@]}" | fzf --multi)

if [[ ${#selected_files[@]} -eq 0 ]]; then
  echo "No files selected."
  exit 1
fi

# Copy selected files to the destination directory
for file in "${selected_files[@]}"; do
  cp "$file" "$DEST_DIR"
  echo "Copied: $file -> $DEST_DIR"
done

echo "Done!"