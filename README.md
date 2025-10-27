# Bengali ALPR (Automatic License Plate Recognition)

## Quick Start (Recommended)

One-command startup and shutdown for macOS and Ubuntu:

### Start the Server

```bash
# Make executable (first time only)
chmod +x start-anpr-server.sh

# Run the server
./start-anpr-server.sh
```

The server will be available at `http://localhost:8000`

### Stop the Server

```bash
# Make executable (first time only)
chmod +x stop-anpr-server.sh

# Stop the server
./stop-anpr-server.sh
```

## Docker Setup

### Prerequisites

1. Download models from: [models](https://drive.google.com/drive/folders/1n3Sp-xZXYxJAzpsFkoe7tEOxvTA_gYO-?usp=sharing)
2. Place the model files in the `models/` directory

### Build and Run with Docker (Manual)

```bash
# Build the Docker image
docker build -t bengali-alpr .

# Run the container (use port 5000 if available)
docker run -p 5000:5000 bengali-alpr

# OR if port 5000 is occupied, use a different host port
docker run -p 8000:5000 bengali-alpr
# Then access at http://localhost:8000
```

The API will be available at `http://localhost:5000` (or the port you specified)

### Troubleshooting

**Port 5000 already in use?**

Option 1: Use a different port

```bash
docker run -p 8000:5000 bengali-alpr
# Access at http://localhost:8000
```

Option 2: Find and stop what's using port 5000

```bash
# Find what's using port 5000
lsof -i :5000

# Stop the process (replace PID with the actual process ID from above)
kill -9 PID
```

### API Endpoints

- `GET /` - Welcome message
- `POST /lp-text` - Extract license plate text from an uploaded image

### Additional Commands

```bash
# View logs
docker logs -f bengali-alpr-server

# Restart stopped container
docker start bengali-alpr-server

# Manually stop (alternative)
docker stop bengali-alpr-server
```

## Local Setup (CPU)

Python version: 3.10.3

Start with `test.py`
