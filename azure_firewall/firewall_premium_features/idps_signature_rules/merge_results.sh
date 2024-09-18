#!/bin/bash

# Specify the source directory
source_directory="./"

# Specify the temporary directory
temp_directory="./temp"

# Count the number of files with the naming pattern "results_#.json"
file_count=$(ls "$source_directory"/results_*.json | wc -l)
echo "Number of files: $file_count"

# Ensure the temporary directory exists
mkdir -p "$temp_directory"

# Copy the first file to the temporary directory, format it as JSON, and remove the last 3 lines
first_file=$(ls -1 "$source_directory"/results_*.json | head -n 1)
cp "$first_file" "$temp_directory/merged_results.json"
jq . "$temp_directory/merged_results.json" > "$temp_directory/merged_results_formatted.json"

sed -i '$d' "$temp_directory/merged_results_formatted.json"
sed -i '$d' "$temp_directory/merged_results_formatted.json"
truncate -s -1 "$temp_directory/merged_results_formatted.json" # Use the truncate command to remove the last byte (which is often a newline) from the file
printf "," >> "$temp_directory/merged_results_formatted.json"

rm "$temp_directory/merged_results.json"
echo "First file ($first_file) processed and formatted in the temporary directory"

# Loop through the remaining files
for ((i=2; i<=file_count-1; i++)); do
    current_file=$(ls -1 "$source_directory"/results_*.json | head -n $i | tail -n 1)
    echo "Processing file: $current_file"

    cp "$current_file" "$temp_directory/temp_copy.json"

    jq . "$temp_directory/temp_copy.json" > "$temp_directory/temp_copy_formatted.json"

    rm "$temp_directory/temp_copy.json"

    sed -i '1,3d' "$temp_directory/temp_copy_formatted.json" # Removes the first 3 lines
    sed -i '$d' "$temp_directory/temp_copy_formatted.json" # Removes the last line
    sed -i '$d' "$temp_directory/temp_copy_formatted.json" # Removes the last line
    truncate -s -1 "$temp_directory/temp_copy_formatted.json" # Use the truncate command to remove the last byte (which is often a newline) from the file
    
    echo "Preparing file for next merge"
    # Add a comma to the last line (except for the last file)
    printf "," >> "$temp_directory/temp_copy_formatted.json"
    sed -i -e '$a\' "$temp_directory/merged_results_formatted.json" # Add a new line to the end of the merged file, because truncate places the cursor at the closing bracket
    cat "$temp_directory/temp_copy_formatted.json" >> "$temp_directory/merged_results_formatted.json"
    rm "$temp_directory/temp_copy_formatted.json"
done

# Process the last file (remove the first 3 lines)
last_file=$(ls -1 "$source_directory"/results_*.json | tail -n 1)

cp "$last_file" "$temp_directory/temp_copy.json"
jq . "$temp_directory/temp_copy.json" > "$temp_directory/temp_copy_formatted.json"
rm "$temp_directory/temp_copy.json"

sed -i '1,3d' "$temp_directory/temp_copy_formatted.json"
sed -i -e '$a\' "$temp_directory/merged_results_formatted.json" # Add a new line to the end of the merged file, because truncate places the cursor at the closing bracket    
cat "$temp_directory/temp_copy_formatted.json" >> "$temp_directory/merged_results_formatted.json"
rm "$temp_directory/temp_copy_formatted.json"

echo "Files processed and merged in the temporary directory: $temp_directory/merged_results_formatted.json"
