# Use the official Nginx image as the base image
FROM nginx:latest

# Install Apache HTTP Server utilities (which include htpasswd)
RUN apt-get update && apt-get install -y apache2-utils

# Copy the existing Nginx configuration and other necessary files
COPY nginx.conf /etc/nginx/nginx.conf
COPY mime.types /etc/nginx/mime.types
COPY proxy_params.conf /etc/nginx/proxy_params.conf
COPY certs/server.crt /etc/nginx/certs/server.crt
COPY certs/server.key /etc/nginx/certs/server.key
COPY nginx-html /usr/share/nginx/html
COPY .htpasswd /etc/nginx/.htpasswd

# Expose ports
EXPOSE 80 443

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]
