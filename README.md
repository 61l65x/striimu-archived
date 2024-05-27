# Docker Media Server Setup

**Important**: Configure a VPN before proceeding. 

> :warning: **Secure Your Connection**: Ensure you have a VPN configured for secure access. Use an existing VPN, set it up to connect through the WireGuard container, or create your own for free on Oracle Cloud. Guide for creating the VCN and VPN, [tutorial on YouTube](https://www.youtube.com/watch?v=wV61_bcABek).

> :bulb: **Real Debrid as an Option**: For enhanced streaming, consider integrating Real Debrid to access high-speed downloads and private streams. Real Debrid can complement a VPN for improved privacy—ideal for those who prioritize security.
<img src="assets/docker.webp" alt="Docker" width="325" align="right">  

### Overview

This Docker Compose file sets up a media server with Jellyfin, Nginx, qBittorrent, Radarr, and Sonarr, Wireguard, stremio and lots of other awesome technologies !

### Inter-Container Communication

Use container names instead of IPs, for example, `http://nameofcontainer:port`.

## Requirements

- Docker
- Docker Compose

## Quick Start

1. **Clone the Repository**

```bash
   git clone --recurse-submodules https://github.com/Jallunator/MyMovieDocker.git
   cd MyMovieDocker
```

2. **Configuration Update the following files and paths**

+ +  Nginx Configuration
+ + SSL certificates if https ( not necessary needed if not in public network )

3. **Start the Services**

+  **Services are controlled with profiles**
+ **Profiles:** all, streaming, install
```bash
# Run the starting script ( Recomended )
./scripts/start_and_monitor_all.sh
# Or specify the profile 
docker compose --profile all up --build -d
```

## Access the Services

This section provides details on how to access each service within our network. **Note**: Only streaming services and the top-level UI (currently in development) are exposed to the Internet.



### Streaming Services

- **Jellyfin** (Media Player)
  - **URL**: `http://localhost:8096`
  - Access media stored and streamed from this server.
  
- **qBittorrent** (Torrent Client)
  - **URL**: `http://localhost:8080`
  - **Default Credentials**: Username: admin | Password: Check via `docker compose logs | grep password`
  - Configured as a download client in Radarr and Sonarr.

#### Integrated Media Management

- **Radarr, Sonarr & Bazarr**
  - These services are tightly integrated to streamline the management of your media library:
    - **Radarr** (Movies): `http://localhost:7878`
      - Manages and downloads movies.
      - Integrated with Jackett for indexer management via URL: `http://jackett:9117/api/v2.0/indexers/all/results/torznab/`.
    - **Sonarr** (TV Series): `http://localhost:8989`
      - Manages and downloads television series.
    - **Bazarr** (Subtitles): `http://localhost:6767`
      - Downloads subtitles automatically, working in conjunction with Sonarr and Radarr.

- **Jackett** (Indexer Management)
  - **URL**: `http://localhost:9117`
  - Central management for various indexers used by Radarr and Sonarr.

- **Stremio** (Media Aggregation)
  - **Stremio Web**: `http://localhost:8081` (Development and internal use)
  - **Stremio Server**: `http://localhost:11470` (Handles media indexing and streaming)

### Support Services

- **FlareSolverr** (CAPTCHA Solver Proxy)
  - For resolving CAPTCHAs encountered by scrapers, used internally.

- **Fail2Ban** (Intrusion Prevention)
  - Monitors log files and bans IPs that show malicious signs.

### Development Tools

- **nginx** (Web Server and Reverse Proxy)
  - Handles requests and serves as the front-facing server.
  - **Configuration Files**: Located at `./nginx/`.

### Network Security

- **WireGuard client under development and also the own VPN server !**

- All services are contained within a secure internal Docker network.
- External access is strictly controlled and monitored through nginx and Fail2Ban.

### Top-Level UI

- **Under Development**: A unified interface to manage all services efficiently.

### Additional Information

- All services are running within an internal Docker network to ensure security and isolation.
- The top-level UI for managing these services is currently under development and will be accessible upon release.
- Ensure that new passwords are configured for all services after installation to secure access.

---

## Monitor Logs
```bash
# With colors
./scripts/docker_logs.sh
# Multi monitoring 
./scripts/logs_stats.sh
```
## Monitor Containers
``` bash
docker stats
```

## Go inside container system
``` bash 
docker exec -it <container name> /bin/sh
```

## Stop Services 
``` bash 
docker-compose down
```

## Clean Up
```bash
docker-compose down -v
```

## File structure
```
Project Root
│
├── assets
│   └── docker.webp
│
├── config
│   ├── bazarr
│   ├── fail2ban
│   ├── jackett
│   ├── jellyfin
│   ├── qbittorrent
│   ├── radarr
│   └── sonarr
│
├── nginx
│   ├── nginx.conf
│   ├── server.crt
│   └── server.key
│
├── scripts
│   ├── do_all.sh
│   ├── docker_logs.sh
│   └── logs_stats.sh
│
├── services
│   ├── bazarr
│   ├── fail2ban
│   ├── jackett
│   ├── jellyfin
│   ├── qbittorrent
│   ├── radarr
│   ├── sonarr
│   ├── stremio-server
│   └── stremio-web
│
├── toplevel-ui
│   ├── backend
│   ├── frontend
│   └── docker-compose.yml
│
├── docker-compose.yml
├── README.md
└── TODO.md

```


## Starting the Services

All paths in the `docker-compose.yml` files are relative to the root folder. Ensure you start the services from the root folder.

```sh
# Navigate to the root folder
cd ~/striimu
# Start the Nginx service
docker compose -f ./docker-compose.yml -f ./server-services/docker-compose.yml up -d nginx
# Start other services as needed
docker compose -f ./docker-compose.yml -f ./media-services/docker-compose.yml up -d
```


```bash
#IMPORTANT ! DOCKER MERGE COMPOSE
Important

When you use multiple Compose files, you must make sure all paths in the files are relative to the base Compose file (the first Compose file specified with -f). This is required because override files need not be valid Compose files. Override files can contain small fragments of configuration. Tracking which fragment of a service is relative to which path is difficult and confusing, so to keep paths easier to understand, all paths must be defined relative to the base file.
```

### Locally debugging with nginx 
```bash

# Start backend
cd ~/striimu/striimu-services/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# Start frontend
cd ~/striimu/striimu-services/frontend
npm install
npm run serve

# Start any services that are included to the server!

# Start Nginx with local debug configuration
# Ensure nginx.local.debug.conf points to host instead of containers
docker compose -f ./docker-compose.yml -f ./server-services/docker-compose.yml up nginx

```
