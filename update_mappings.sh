#!/bin/bash

# Ensure the script is called with a comma-separated list of file paths
if [[ -z "$1" ]]; then
  echo "Error: Please provide a comma-separated list of transform file paths."
  exit 1
fi

# File paths
MAPPING_FILE="mappings.json"

# Convert comma-separated list of file paths into an array
if [[ "$1" == *,* ]]; then
    IFS=',' read -r -a TRANSFORM_FILES <<< "$1"
else
    TRANSFORM_FILES=("$1")
fi

# Check if we're in the dev or main branch
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Function to update the mappings.json file with id and name from the transform
update_mappings_file() {
  local transform_file="$1"
  local new_transform_id
  local transform_name
  
  # Create transform and get the ID and name
  new_transform_id=$(jq -r '.id' < "$transform_file")
  transform_name=$(jq -r '.name' < "$transform_file")

  echo "Processing transform: $transform_name with ID: $new_transform_id"

  if [[ "$BRANCH_NAME" == "dev" ]]; then
    # Add a new key with the transform name in dev
    echo "Adding new transform ID and name to mappings.json in dev for $transform_name."
    
    # Add a new key with the new ID and set the value to the transform name
    jq --arg id "$new_transform_id" --arg name "$transform_name" '.ids[$id] = $name' "$MAPPING_FILE" > tmp.$$.json && mv tmp.$$.json "$MAPPING_FILE"

  elif [[ "$BRANCH_NAME" == "main" ]]; then
    # Update the ID in main by replacing the name with the actual ID
    echo "Updating transform ID in mappings.json in main for $transform_name."

    # Find the matching key (the ID with the value being the transform name from dev) and update the value with the new ID from main
    jq --arg name "$transform_name" --arg new_id "$new_transform_id" '
      .ids |= with_entries(if .value == $name then .value = $new_id else . end)
    ' "$MAPPING_FILE" > tmp.$$.json && mv tmp.$$.json "$MAPPING_FILE"
  fi
}

# Process each transform file passed in the list
for transform_file in "${TRANSFORM_FILES[@]}"; do
  # Check if the file exists and has a .json extension
  if [[ -f "$transform_file" && "$transform_file" == *.json && "$transform_file" == *transform_files* ]]; then
    update_mappings_file "$transform_file"
  else
    echo "Skipping non-JSON file or file not found: $transform_file"
  fi
done

# Pull the latest transforms to get the new IDs
rm -rf transform_files
sail transform download

sleep 5

# Commit and push changes
if [[ "$BRANCH_NAME" == "dev" ]]; then
  git add "$MAPPING_FILE"
  
  for transform_file in "${TRANSFORM_FILES[@]}"; do
    if [[ -f "$transform_file" && "$transform_file" == *.json && "$transform_file" == *transform_files* ]]; then
      git add "$transform_file"
    fi
  done

  git commit -m "Add/update multiple transform IDs in dev."
  git push origin dev

elif [[ "$BRANCH_NAME" == "main" ]]; then
  git add "$MAPPING_FILE"
  
  for transform_file in "${TRANSFORM_FILES[@]}"; do
    if [[ -f "$transform_file" && "$transform_file" == *.json && "$transform_file" == *transform_files* ]]; then
      git add "$transform_file"
    fi
  done

  git commit -m "Update multiple transform IDs in main."
  git push origin main

  # Reset the changes so that we can switch back to dev
  git reset --hard HEAD

  # Switch to dev branch to update mappings.json with the new IDs
  echo "Switching to dev branch to update the mappings with new transform IDs."
  git checkout dev

  # Pull the latest transforms so that we can map the IDs correctly
  rm -rf transform_files
  sail transform download 

  sleep 5

  # Process each transform file again to update the dev branch
  for transform_file in "${TRANSFORM_FILES[@]}"; do
    if [[ -f "$transform_file" && "$transform_file" == *.json && "$transform_file" == *transform_files* ]]; then
      update_mappings_file "$transform_file"
    fi
  done

  git status
  
  # Commit and push changes to dev
  git add "$MAPPING_FILE"
  git commit -m "Update transform IDs with the new ones in dev."
  git push origin dev

  # Reset the changes so that we can switch back to main
  git reset --hard HEAD

  # Switch back to main
  git checkout main
fi

# Log completion
echo "Mappings updated successfully."
