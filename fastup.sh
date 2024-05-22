#!/bin/bash

# Define profiles
declare -a profiles=("streaming" "install" "striimu")

# Get the current working directory
ROOT_DIR=$(pwd)

# Function to start Docker Compose services
function docker_compose_up()
{
    for profile in "${selected_profiles[@]}"; do
        echo "Starting $profile..."
        docker compose -f ${ROOT_DIR}/docker-compose.yml \
        -f ${ROOT_DIR}/server-services/docker-compose.yml \
        -f ${ROOT_DIR}/media-services/docker-compose.yml \
        -f ${ROOT_DIR}/striimu-services/docker-compose.yml \
        --profile $profile up
    done
}

# Function to open the monitoring window
function monitor_window() {
    read -p "Do you want to open the monitoring window? (y/n): " monitor_answer
    if [[ "$monitor_answer" != "y" ]]; then
        docker compose --profile $profile logs --follow --timestamps
        exit 0
    fi

    interface=$(iw dev | grep Interface | awk '{print $2}')
    tmux new-session -d -s docker_monitor
    tmux split-window -h
    tmux select-pane -t 0
    tmux send-keys "docker compose -f ${ROOT_DIR}/striimu-services/docker-compose.yml -f ${ROOT_DIR}/media-services/docker-compose.yml --profile $profile logs --follow --timestamps | ccze -A" C-m
    tmux select-pane -t 1
    tmux send-keys "sudo iftop -i $interface" C-m
    tmux split-window -v
    tmux select-pane -t 2
    tmux send-keys "docker stats" C-m
    tmux select-pane -t 3
    tmux send-keys "while true; do sudo lsof -i -P -n | grep docker; sleep 10; clear; done" C-m
    tmux select-pane -t 3
    tmux split-window -v
    tmux select-pane -t 4
    tmux send-keys "watch -n 1 'docker ps'" C-m
    tmux attach-session -t docker_monitor
    echo "Press ctrl+b to control tmux"
}

# Function to get profile choices from the user
function get_profile_choices() {
    echo "Available profiles:"
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[$i]}"
    done
    echo "4. All"
    echo "Enter the numbers of the profiles you want to start (comma-separated), or '4' for all:"
    read -p "Input: " input
    IFS=',' read -ra choices <<< "$input"
    selected_profiles=()

    for choice in "${choices[@]}"; do
        if [[ "$choice" -eq 4 ]]; then
            selected_profiles=("all")
            break
        elif ((choice > 0 && choice <= ${#profiles[@]})); then
            selected_profiles+=("${profiles[$((choice-1))]}")
        else
            echo "Invalid choice: $choice"
            exit 1
        fi
    done
    echo "Selected profiles: ${selected_profiles[@]}"
}

# Function to display information
function display_info() {
    ./assets/scripts/INFO.sh
}

# Function to clean Docker containers
function docker_clean_containers() {
    docker stop $(docker ps -q)
    docker rm $(docker ps -a -q)
}

# Main function
function main() {
    display_info
    get_profile_choices
    docker_compose_up
    #monitor_window
}

# Run the main function
main
