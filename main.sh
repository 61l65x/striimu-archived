#!/bin/bash

# Define profiles -- Global variables
declare -a profiles=("streaming" "install" "striimu" "server")
ROOT_DIR=$(pwd)

source ./assets/scripts/docker_functions.sh
source ./assets/scripts/info.sh
source ./assets/scripts/monitor_functions.sh


# Main function
function docker_commands_menu() {
    while true; do
        DOCKER_CHOICE=$(whiptail --title "Docker Commands Menu" --menu "Choose a Docker command" 15 60 6 \
        "1" "Clean Docker Containers" \
        "2" "Compose Up with Profiles" \
        "3" "Compose Down Containers" \
        "4  " "Build Containers" \
        "5" "Back to Main Menu" 3>&1 1>&2 2>&3)

        case $DOCKER_CHOICE in
            1)
                docker_clean_containers
                ;;
            2)
                docker_compose_up
                ;;
            3)
                docker_compose_down
                ;;
            4)
                docker_compose_build
                ;;
            5)
                break
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
    done
}

# Main function
function main() {
    while true; do
        CHOICE=$(whiptail --title "Main Menu" --menu "Choose an action" 15 60 5 \
        "1" "Display Information" \
        "2" "Docker Commands" \
        "3" "Open Monitor Window" \
        "4" "Exit" 3>&1 1>&2 2>&3)

        case $CHOICE in
            1)
                display_info
                ;;
            2)
                docker_commands_menu
                ;;
            3)
                monitor_window
                ;;
            4)
                exit 0
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
    done
}

# Run the main function
main

