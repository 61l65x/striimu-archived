# My Movie Docker

This project sets up a Jellyfin media server using Docker and Nginx as a reverse proxy. Follow the instructions below to set up and use the server.

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

#### Create a Certificate Authority:

1. **Generate a private key for your CA**:

    ```bash
    openssl genpkey -algorithm RSA -out ca.key -aes256
    ```

2. **Create a public certificate for your CA**:

    ```bash
    openssl req -x509 -new -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=MyTestCA"
    ```

#### Create a Server Certificate:

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

#### Update Nginx Configuration

1. **Update the Nginx configuration**:

   Replace the certificate and key paths in `nginx.conf` with the paths to the new certificate (`server.crt`) and key (`server.key`).

2. **Restart the Docker containers**:

    ```bash
    docker-compose down
    docker-compose up -d
    ```

### Cleanup

- **Remove unused Docker objects**:

    ```bash
    docker system prune -f
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
