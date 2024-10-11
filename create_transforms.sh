#!/bin/bash

#####################################################################
# This script is meant to be used if you need to copy the           #
# transforms to your production environment from sandbox.           #
# This transform does not transfer any internal transforms          #


# Directory containing the JSON files
TRANSFORM_DIR="transform_files"

# Check if the directory exists
if [ ! -d "$TRANSFORM_DIR" ]; then
  echo "Directory $TRANSFORM_DIR does not exist."
  exit 1
fi

# Loop through each JSON file in the directory
for file in "$TRANSFORM_DIR"/*.json; do
  # Check if the file exists (in case no .json files are found)
  if [ -f "$file" ]; then
    # Check if the 'internal' field is false using jq
    is_internal=$(jq -r '.internal' "$file")

    # Proceed if 'internal' is false
    if [[ "$is_internal" == "false" ]]; then
      echo "Processing file: $file (internal: false)"
      
      # Call the sail transform create command for each file
      sail transform create -f "$file"

      # Check if the command was successful
      if [ $? -ne 0 ]; then
        echo "Failed to create transform for file: $file"
        exit 1
      fi
    else
      echo "Skipping file: $file (internal: $is_internal)"
    fi
  else
    echo "No JSON files found in the directory."
    exit 1
  fi
done

echo "All applicable transforms created successfully."

