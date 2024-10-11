#!/bin/bash

# Path to the JSON file containing the ID mappings
MAPPING_FILE="mappings.json"

# Directory containing the JSON files to modify
TRANSFORM_DIR="transform_files"

# Check if the mapping file exists
if [ ! -f "$MAPPING_FILE" ]; then
  echo "Mapping file $MAPPING_FILE does not exist."
  exit 1
fi

# Check if the directory exists
if [ ! -d "$TRANSFORM_DIR" ]; then
  echo "Directory $TRANSFORM_DIR does not exist."
  exit 1
fi

# Loop through each JSON file in the directory
for file in "$TRANSFORM_DIR"/*.json; do
  # Check if the file exists (in case no .json files are found)
  if [ -f "$file" ]; then
    echo "Processing file: $file"
    
    # Read each mapping from the JSON file and replace IDs
    while IFS="=" read -r old_id new_id; do
      echo "Replacing $old_id with $new_id in $file"
      
      # Use sed to replace the old ID with the new ID in the file
      sed -i "" "s|$old_id|$new_id|g" "$file"
      
    # Extract the ID mappings using jq and pass them to the loop
    done < <(jq -r '.ids | to_entries[] | "\(.key)=\(.value)"' "$MAPPING_FILE")
  fi
done

echo "ID replacement complete."
