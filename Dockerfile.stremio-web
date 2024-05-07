# Dockerfile.stremio-web

# Build stage
FROM node:20-alpine AS build

# Meta
LABEL Description="Stremio Web" Vendor="Smart Code OOD" Version="1.0.0"

WORKDIR /var/www/stremio-web

# Install git and clone the repository
RUN apk add --no-cache git
RUN git clone https://github.com/Stremio/stremio-web.git .

# Build the application
RUN npm install
RUN npm run build

# Final stage
FROM node:20-alpine AS final
WORKDIR /var/www/stremio-web

# Copy the built files from the build stage
COPY --from=build /var/www/stremio-web .

EXPOSE 8080
CMD ["node", "http_server.js"]
