# My Movie Docker

This project sets up a Jellyfin media server using Docker, Nginx as a reverse proxy, and qBittorrent as a torrent client. Follow the instructions below to set up and use the server.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) installed.
- [Docker Compose](https://docs.docker.com/compose/install/) installed.

### Running the Server

To run the server:

1. **Build and start the Docker containers**:

    ```bash
    docker-compose up -d
    ```

2. **Access Jellyfin**:

   - Open your browser and go to [http://localhost:8096](http://localhost:8096) or [https://localhost:443](https://localhost:443).
   - Follow the setup wizard to configure Jellyfin.

3. **Access qBittorrent**:

   - Open your browser and go to [http://localhost:8080](http://localhost:8080).
   - The default username and password can be found in the Docker logs. Run the following command to view the logs:

    ```bash
    docker-compose logs qbittorrent
    ```

   - Look for a line similar to this one:
     ```
     qBittorrent username: admin, password: <some_random_password>
     ```

 ### **Adding qBittorrent Library to Jellyfin**:
1. Open your web browser and go to http://localhost:8096.
2. Add qBittorrent Download Folder as a Library:
+ Go to Dashboard > Libraries > Add Media Library.
+ Set the Content Type to Movies or TV Shows.
+ Set the Library Path to /downloads.


### Managing the Containers

- **Check the status of the containers**:

    ```bash
    docker ps
    ```

- **Stop the containers**:

    ```bash
    docker-compose down
    ```

### Debugging

- **View the logs**:

    ```bash
    docker-compose logs -f
    ```

### Setting up SSL/TLS

For testing purposes, this setup uses self-signed SSL certificates, which will show a "Not Secure" warning in the browser.

#### Self-Signed Certificate (for internal use):

##### Create a Certificate Authority:

1. **Generate a private key for your CA**:

    ```bash
    openssl genpkey -algorithm RSA -out ca.key -aes256
    ```

2. **Create a public certificate for your CA**:

    ```bash
    openssl req -x509 -new -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=MyTestCA"
    ```

##### Create a Server Certificate:

1. **Generate a private key for the server**:

    ```bash
    openssl genpkey -algorithm RSA -out server.key
    ```

2. **Create a certificate signing request (CSR)**:

    ```bash
    openssl req -new -key server.key -out server.csr -subj "/CN=192.168.63.159"
    ```

3. **Sign the server CSR with the CA certificate**:

    ```bash
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256
    ```

#### Let's Encrypt Certificate (for public use):

To obtain a publicly trusted SSL certificate using Let's Encrypt:

1. **Install Certbot**:

   - **Ubuntu/Debian**:

     ```bash
     sudo apt-get update
     sudo apt-get install certbot python3-certbot-nginx
     ```

   - **RHEL/CentOS**:

     ```bash
     sudo yum install certbot python3-certbot-nginx
     ```

2. **Stop Nginx**:

    ```bash
    docker-compose stop nginx
    ```

3. **Request a Certificate**:

    ```bash
    sudo certbot certonly --standalone -d example.com
    ```

4. **Update Nginx Configuration**:

    ```nginx
    server {
        listen 443 ssl;
        server_name example.com;

        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        location / {
            proxy_pass http://jellyfin:8096;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```

5. **Update Docker Compose**:

    ```yaml
    version: '3.7'

    services:
      jellyfin:
        image: jellyfin/jellyfin
        container_name: jellyfin
        ports:
          - "8096:8096"
        volumes:
          - ./config:/config
          - ./cache:/cache
          - ./media:/media
        restart: unless-stopped

      nginx:
        image: nginx
        container_name: nginx
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - ./nginx.conf:/etc/nginx/nginx.conf
          - /etc/letsencrypt:/etc/letsencrypt
        depends_on:
          - jellyfin
        restart: unless-stopped

      qbittorrent:
        image: linuxserver/qbittorrent
        container_name: qbittorrent
        ports:
          - "8080:8080"
          - "6881:6881"
          - "6881:6881/udp"
        volumes:
          - ./downloads:/downloads
          - ./config/qbittorrent:/config
        environment:
          - PUID=1000
          - PGID=1000
          - TZ=Etc/UTC
          - WEBUI_PORT=8080
        restart: unless-stopped
    ```

6. **Renewal**:

    Certbot automatically renews the certificates, but you can add a cron job to restart Nginx:

    ```bash
    sudo crontab -e
    ```

    Add this line:

    ```bash
    0 0 * * 0 certbot renew --quiet --deploy-hook "docker-compose restart nginx"
    ```

### Cleanup

- **Remove unused Docker objects**:

    ```bash
    docker system prune -f
    ```

### Useful commands
```bash 
# see all docker processes internet filedescriptors
sudo lsof -i | grep docker
```



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

