#!/bin/bash

# Bengali ALPR Server Startup Script

echo "Starting Bengali ALPR Server..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker."
    exit 1
fi

# Check if image exists, if not, build it
if ! docker image inspect bengali-alpr > /dev/null 2>&1; then
    echo "Building Docker image..."
    docker build -t bengali-alpr .
    echo "Image built successfully"
else
    echo "Using existing image: bengali-alpr"
fi

# Stop any existing container with the same image
echo "Stopping existing containers (if any)..."
docker stop $(docker ps -q --filter ancestor=bengali-alpr) > /dev/null 2>&1
docker rm $(docker ps -aq --filter ancestor=bengali-alpr) > /dev/null 2>&1

# Run the container
echo "Starting container on port 8000..."
docker run -d -p 8000:5000 --name bengali-alpr-server bengali-alpr

# Wait a moment for the container to start
sleep 2

# Check if container is running
if docker ps | grep -q bengali-alpr-server; then
    echo "Server started successfully!"
    echo ""
    echo "API available at: http://localhost:8000"
    echo ""
    echo "Quick commands:"
    echo "  - View logs: docker logs -f bengali-alpr-server"
    echo "  - Stop server: docker stop bengali-alpr-server"
    echo "  - Remove server: docker rm bengali-alpr-server"
    echo ""
    echo "Test the API:"
    echo "  curl http://localhost:8000"
    echo ""
else
    echo "Failed to start container"
    docker logs bengali-alpr-server
    exit 1
fi

