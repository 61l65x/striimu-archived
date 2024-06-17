#!/bin/bash

# Function to add a user to the .htpasswd file
add_user() {
    read -p "Enter the username to add: " username
    htpasswd server-services/nginx/.htpasswd "$username"
}

# Function to prompt for rebuilding images
prompt_rebuild() {
    read -p "Do you want to rebuild the images? (y/n): " rebuild
    if [[ "$rebuild" == "y" ]]; then
        REBUILD_FLAG=true
    else
        REBUILD_FLAG=false
    fi
}

# Prompt the user to choose the mode
echo "Please choose the mode to start the services:"
echo "1) Development"
echo "2) Production"
echo "3) Add a user to .htpasswd"
read -p "Enter the number (1, 2, or 3): " mode

# Define the default Docker Compose files
COMPOSE_FILES="docker-compose.yml"

# Set the mode based on user input
case $mode in
    1)
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.override.yml"
        echo "Starting in development mode..."
        prompt_rebuild
        ;;
    2)
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.prod.yml"
        echo "Starting in production mode..."
        prompt_rebuild
        ;;
    3)
        add_user
        exit 0
        ;;
    *)
        echo "Invalid selection. Please enter 1, 2, or 3."
        exit 1
        ;;
esac

# Rebuild the images if the user chose to do so
if $REBUILD_FLAG; then
    docker compose -f $COMPOSE_FILES build --no-cache
fi

# Run Docker Compose with the specified files
docker compose -f $COMPOSE_FILES up
