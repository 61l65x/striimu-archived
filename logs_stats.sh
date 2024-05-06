#!/bin/bash

# Create a new tmux session named 'docker_monitor'
tmux new-session -d -s docker_monitor

# Split the window horizontally into two panes
tmux split-window -h

# In the left pane (pane 0), show the Docker logs
tmux send-keys -t docker_monitor:0.0 "docker compose logs --follow --timestamps | ccze -A" C-m

# In the right pane (pane 1), split vertically into two panes
tmux split-window -v

# In the top right pane (pane 1.0), show Docker stats
tmux send-keys -t docker_monitor:0.1 "docker stats" C-m

# In the bottom right pane (pane 1.1), monitor Docker sockets with lsof
tmux send-keys -t docker_monitor:0.2 "while true; do sudo lsof -i -P -n | grep docker; sleep 10; clear; done" C-m

# Attach to the tmux session
tmux attach-session -t docker_monitor
