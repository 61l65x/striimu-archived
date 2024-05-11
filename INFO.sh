#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${GREEN}Docker Media Server Management Script${NC}"
echo -e "${GREEN}-------------------------------------${NC}"
echo ""

# General Commands
echo -e "${YELLOW}Commands:${NC}"
echo "1. Start All Services: 'docker compose up -d'"
echo "2. Stop All Services: 'docker compose down'"
echo "3. Rebuild All Services: 'docker compose up -d --build'"
echo ""

# Profiles Section
echo -e "${BLUE}Profiles:${NC}"
echo "  - Streaming: Only start services needed for streaming."
echo "  - Install: Only start services needed for media downloading and management."
echo ""

# Profile Commands
echo -e "${BLUE}Profile Commands:${NC}"
echo "  a) Start Streaming Services: 'docker compose --profile streaming up -d'"
echo "  b) Stop Streaming Services: 'docker compose --profile streaming down'"
echo "  c) Start Install Services: 'docker compose --profile install up -d'"
echo "  d) Stop Install Services: 'docker compose --profile install down'"
echo ""

# Utility Commands
echo -e "${RED}Utility Commands:${NC}"
echo "  i) View logs for a specific service: 'docker compose logs [service_name] --follow'"
echo "  ii) View running containers: 'docker ps'"
echo "  iii) Stop a specific container: 'docker stop [container_id or name]'"
echo "  iv) Start a specific container: 'docker start [container_id or name]'"
echo ""

# Additional Information
echo -e "${GREEN}For detailed service status, use: 'docker compose ps'${NC}"
echo ""
echo -e "${RED}Note: Always ensure Docker is correctly installed and configured on your system.${NC}"
