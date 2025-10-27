#!/bin/bash

# Bengali ALPR Server Stop Script

echo "Stopping Bengali ALPR Server..."

# Stop the container
if docker ps | grep -q bengali-alpr-server; then
    docker stop bengali-alpr-server
    echo "Server stopped successfully!"
else
    echo "No running server found."
    # Check if container exists but is stopped
    if docker ps -a | grep -q bengali-alpr-server; then
        echo "Container exists but is not running."
        echo "To remove it: docker rm bengali-alpr-server"
    fi
fi

