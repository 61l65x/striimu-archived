# Docker Media Server Setup
## Fast setup for running in local network with http !
## Overview

This Docker Compose file sets up a media server with Jellyfin, Nginx, qBittorrent, Radarr, and Sonarr.

## Requirements

- Docker
- Docker Compose

## Quick Start

1. **Clone the Repository**

```bash
   git clone https://github.com/Jallunator/MyMovieDocker.git
   cd 
```

2. **Configuration Update the following files and paths**

+ +  Nginx Configuration
+ + SSL certificates if https ( not necessary needed if not in public network )
+ + TECH_README if want to configure more ! 

3. **Start the Services**
```bash
docker-compose up -d
```

4. **Access the Services**
+ Jellyfin: http://localhost:8096
+ qBittorrent: http://localhost:8080
+ Radarr: http://localhost:7878
+ Sonarr: http://localhost:8989

## File structure
```
├── config/
│   ├── jellyfin/
│   ├── qbittorrent/
│   ├── radarr/
│   └── sonarr/
├── cache/
├── media/
├── downloads/
├── nginx.conf
├── server.crt
└── server.key
```
## Monitor Logs
```bash
# With colors
./docker_logs.sh
# Basic
watch docker compose logs --follow --timestamps
```

## Stop Services 
``` bash 
docker-compose down
```

## Clean Up
```bash
docker-compose down -v
```
