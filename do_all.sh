#!/bin/bash

# Install Docker and Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose google-chrome-stable
# Clone the repository (replace with your repository URL)
# git clone <repository-url>
# cd <repository-directory>

# Start the Docker Compose services
docker-compose up -d

# Wait for services to start
sleep 15

# Open services in Chrome
google-chrome --new-tab http://localhost:8096 \
              --new-tab http://localhost:8080 \
              --new-tab http://localhost:7878 \
              --new-tab http://localhost:8989
