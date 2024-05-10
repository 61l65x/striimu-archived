#!/bin/bash

# Create a new tmux session named 'docker_monitor'
tmux new-session -d -s docker_monitor

# Split the main window horizontally
tmux split-window -h

# Select the left pane and configure Docker logs
tmux select-pane -t 0
tmux send-keys "docker compose logs --follow --timestamps | ccze -A" C-m

# Move to the right pane, split it vertically
tmux select-pane -t 1
tmux split-window -v

# Select the top right pane, split it vertically again
tmux select-pane -t 2
tmux split-window -v

# Display Docker stats in the top right pane
tmux select-pane -t 2
tmux send-keys "docker stats" C-m

# Monitor Docker sockets with lsof in the middle right pane
tmux select-pane -t 3
tmux send-keys "while true; do sudo lsof -i -P -n | grep docker; sleep 10; clear; done" C-m

# Display network traffic with iftop in the bottom right pane
tmux select-pane -t 1
tmux send-keys "sudo iftop" C-m

# Attach to the tmux session
tmux attach-session -t docker_monitor
