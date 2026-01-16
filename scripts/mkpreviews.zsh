#!/bin/zsh
set -euo pipefail

# Create PNG previews for TIFF images in a folder.
# Usage: ./make_previews.zsh /path/to/folder
# Output: same folder, filename_preview.png

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

DIR="$1"

if [[ ! -d "$DIR" ]]; then
  echo "Error: not a directory: $DIR"
  exit 1
fi

# "Reasonable" preview size: longest edge = 2048px
MAX_EDGE=1280

found_any=0
while IFS= read -r -d '' infile; do
  found_any=1

  in_dir="${infile:h}"
  base="${infile:t:r}"                 # filename without extension
  out="${in_dir}/${base}_preview.png"

  # Avoid generating preview_preview.png
  if [[ "${base}" == *_preview ]]; then
    echo "Skipping (already preview-named): $infile"
    continue
  fi

  # Skip if preview already exists
  if [[ -e "$out" ]]; then
    echo "Skipping (preview exists): $out"
    continue
  fi

  echo "Creating: $out"
  sips -s format png "$infile" --out "$out" >/dev/null
  sips --resampleHeightWidthMax "$MAX_EDGE" "$out" >/dev/null
done < <(find "$DIR" -type f \( -iname "*.tif" -o -iname "*.tiff" \) -print0)

if [[ $found_any -eq 0 ]]; then
  echo "No TIFF files found in: $DIR"
fi

