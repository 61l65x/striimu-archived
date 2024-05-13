#!/bin/bash

# !!!!! ADD TO SUDOERS FILE !!!!!
# username ALL=(ALL) NOPASSWD: /usr/sbin/iftop, /usr/bin/lsof

# Define profiles
declare -a profiles=("streaming" "install")

# Display profiles to user
echo "Available profiles:"
for i in "${!profiles[@]}"; do
  echo "$((i+1)). ${profiles[$i]}"
done
echo "3. All"

# Prompt for profile choice
echo "Enter the numbers of the profiles you want to start (comma-separated), or '3' for all:"
read -p "Input: " input

# Process input
IFS=',' read -ra choices <<< "$input"
selected_profiles=()

for choice in "${choices[@]}"; do
  if [[ "$choice" -eq 3 ]]; then
    selected_profiles=("all")
    break
  elif ((choice > 0 && choice <= ${#profiles[@]})); then
    selected_profiles+=("${profiles[$((choice-1))]}")
  else
    echo "Invalid choice: $choice"
    exit 1
  fi
done

# Start selected profiles
for profile in "${selected_profiles[@]}"; do
  echo "Starting $profile..."
  docker compose --profile "$profile" up -d
done

# Ask for monitoring window
read -p "Do you want to open the monitoring window? (y/n): " monitor_answer

if [[ "$monitor_answer" == "y" ]]; then
    tmux new-session -d -s docker_monitor
    tmux split-window -h
    tmux select-pane -t 0
    tmux send-keys "docker compose --profile $profile logs --follow --timestamps | ccze -A" C-m
    tmux select-pane -t 1
    tmux send-keys "sudo iftop -i wlp41s0" C-m
    tmux split-window -v
    tmux select-pane -t 2
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
fi

echo "Use sudo iftop -i wlp41s0 to monitor network traffic !!"
