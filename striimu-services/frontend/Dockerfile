# Stage 1: Build the Vue.js application
FROM node:14 AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Serve the application with a custom Express server
FROM node:14-alpine

WORKDIR /app

# Copy the build artifacts from the build stage
COPY --from=build-stage /app/dist /app/dist

# Copy the server script
COPY server.js /app

# Install dependencies required for the server
RUN npm install express

EXPOSE 8080
CMD ["node", "server.js"]
