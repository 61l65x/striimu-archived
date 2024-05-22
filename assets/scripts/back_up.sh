#!/bin/bash

# Scan all mounted devices in /media
echo "Scanning all devices in /media..."
devices=($(ls /media/alex/))

# Check if no devices are found
if [ ${#devices[@]} -eq 0 ]; then
  echo "No devices found in /media."
  exit 1
fi

# Display the list of devices to the user
echo "Found the following devices:"
for i in "${!devices[@]}"; do
  echo "$i) ${devices[$i]}"
done

# Ask the user to choose the correct device
read -p "Enter the number of the device to use for backup: " device_index

# Validate the user input
if [[ ! "$device_index" =~ ^[0-9]+$ ]] || [ "$device_index" -ge "${#devices[@]}" ] || [ "$device_index" -lt 0 ]; then
  echo "Invalid selection."
  exit 1
fi

selected_device=${devices[$device_index]}

# Set the backup path
backup_path="/media/alex/$selected_device/striimu-backup/"

# Perform the backup using rsync
echo "Backing up to $backup_path..."
rsync -av --exclude='.git' --exclude='node_modules' ~/striimu/ "$backup_path"

echo "Backup completed successfully."

