#!/bin/bash
set -e

TARGET_DIR="/home/arman/rising-ci/out"

# Uploads a file to Gofile and returns the download link
upload_to_gofile() {
  local file="$1"
  SERVER=$(curl -s https://api.gofile.io/servers | jq -r '.data.servers[0].name')
  
  # Attempt upload to Gofile and extract the download link
  LINK=$(curl -s -F "file=@$file" "https://${SERVER}.gofile.io/uploadFile" | jq -r '.data.downloadPage') 2>/dev/null
  
  # Check if the upload succeeded
  if [[ -n "$LINK" ]]; then
    echo "$LINK"  # Print ONLY the link to stdout
    return 0
  else
    echo "Error: Gofile upload failed for $file." >&2
    return 1
  fi
}

cd "$TARGET_DIR"

ERROR_LOG_LINK=""

# Upload error.log files
FILES=(error*.log)
for FILE in "${FILES[@]}"; do
  if [ ! -e "$FILE" ]; then
    echo "Error: File '$FILE' not found in $TARGET_DIR." >&2
    exit 1
  fi
  echo "Attempting to upload $FILE to Gofile." >&2
  GOFILE_LINK=$(upload_to_gofile "$FILE") || exit 1
  ERROR_LOG_LINK="$ERROR_LOG_LINK $GOFILE_LINK"
done

echo "ERROR_LOG_LINK=${ERROR_LOG_LINK}" >> $GITHUB_ENV
