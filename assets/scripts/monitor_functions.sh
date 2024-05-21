#!/bin/bash

function monitor_window()
{
    interface=$(iw dev | grep Interface | awk '{print $2}')
    tmux new-session -d -s docker_monitor
    tmux split-window -h
    tmux select-pane -t 0
    tmux send-keys "docker compose  -f ${ROOT_DIR}/docker-compose.yml \
                                    -f ${ROOT_DIR}/server-services/docker-compose.yml \
                                    -f ${ROOT_DIR}/media-services/docker-compose.yml \
                                    -f ${ROOT_DIR}/striimu-services/docker-compose.yml \
                                    --profile $profile logs --follow --timestamps | ccze -A" C-m
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
