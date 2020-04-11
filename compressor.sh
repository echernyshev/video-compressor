#!/bin/bash
fullPath=$(realpath "$1")
if [ ! -d "$fullPath" ]; then
  echo "Directory $fullPath is not exists"
  exit 1
fi
echo "Work in directory ${fullPath}"

backup="$fullPath/backup$(date +"%Y%m%d-%H%M%S")"
if mkdir "$backup"; then
  echo "Backup dir $backup created"
fi

for filename in "$fullPath"/*.mp4; do
  echo "Copy file $filename to $backup"
  if ! cp "$filename" "$backup"; then
    echo "Error copying backup file. Skip compressing"
    break
  fi
  decompressed="${filename%.mp4}.raw.mp4"
  mv "$filename" "$decompressed"
  if ffmpeg -i "$decompressed" -vcodec libx265 -crf 30 "$filename"; then
    echo "Success compressed ${filename}"
    rm "$decompressed"
  fi
done
