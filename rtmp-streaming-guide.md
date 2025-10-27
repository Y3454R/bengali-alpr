# RTMP Streaming Setup Guide - ANPR Demo

Complete guide for setting up RTMP streaming with MediaMTX and ffmpeg for the Bengali ALPR demo.

## Repository

**Demo Images Repository**: [anpr_demo_stream](https://github.com/Y3454R/anpr_demo_stream.git)

- Contains `imageA.jpg` and `imageB.jpeg` for creating the demo RTMP stream

## Prerequisites

1. **ffmpeg** installed

   ```bash
   # macOS
   brew install ffmpeg

   # Ubuntu
   sudo apt-get install ffmpeg
   ```

2. **MediaMTX** server

   **Option A: Download Pre-built Binary (Recommended)**

   ```bash
   # macOS
   wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_v1.5.1_darwin_amd64.zip
   unzip mediamtx_v1.5.1_darwin_amd64.zip

   # Ubuntu/Linux (amd64)
   wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_v1.5.1_linux_amd64.tar.gz
   tar -xzf mediamtx_v1.5.1_linux_amd64.tar.gz
   ```

   **Option B: Clone and Build from Source**

   ```bash
   git clone https://github.com/bluenviron/mediamtx.git
   cd mediamtx
   make
   ```

   Then run: `./mediamtx`

## Quick Start

### 0. Clone the Demo Images Repository

```bash
git clone https://github.com/Y3454R/anpr_demo_stream.git
cd anpr_demo_stream
```

### 1. Create Video Content

Create a looping video from the demo images:

```bash
ffmpeg \
  -loop 1 -t 3 -i imageA.jpg \
  -loop 1 -t 30 -i imageB.jpeg \
  -loop 1 -t 3 -i imageA.jpg \
  -filter_complex "
    [0:v]scale=1280:720:force_original_aspect_ratio=decrease,\
         pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];
    [1:v]scale=1280:720:force_original_aspect_ratio=decrease,\
         pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];
    [2:v]scale=1280:720:force_original_aspect_ratio=decrease,\
         pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1[v2];
    [v0][v1][v2]concat=n=3:v=1:a=0[out]
  " \
  -map "[out]" -c:v libx264 -pix_fmt yuv420p output.mp4
```

### 2. Start MediaMTX Server

```bash
# Navigate to MediaMTX directory
cd ~/mediamtx

# Run the server
./mediamtx
```

The server will start on:

- RTMP: `rtmp://localhost/live/STREAM_NAME`
- HLS: `http://localhost:8888/STREAM_NAME/hls.m3u8`

### 3. Stream to RTMP

Stream your video to the RTMP server:

```bash
ffmpeg -re -stream_loop -1 -i output.mp4 \
  -c:v libx264 \
  -preset ultrafast \
  -tune zerolatency \
  -b:v 2000k \
  -c:a aac \
  -f flv \
  rtmp://localhost/live/loopedstream
```

## Configuration

### MediaMTX Configuration

Edit `mediamtx.yml`:

```yaml
# RTMP configuration
rtmp:
  encryption: "strict"
  port: 1935
  readTimeout: 10s
  writeTimeout: 10s
  rtmpAddress: ":1935"

# HLS configuration
hls:
  enabled: yes
  address: :8888
  defaultPath: /
  key: "mykey"
  certificate: ""
  readTimeout: 10s
```

## Common Commands

### Basic Loop Stream

```bash
# Loop video indefinitely to RTMP
ffmpeg -re -stream_loop -1 -i video.mp4 \
  -c:v libx264 -preset ultrafast -c:a aac \
  -f flv rtmp://localhost/live/mystream
```

### Webcam Stream (USB Camera)

```bash
# macOS
ffmpeg -f avfoundation -framerate 30 \
  -video_size 1280x720 -i "0" \
  -c:v libx264 -preset veryfast -b:v 2000k \
  -c:a aac -f flv rtmp://localhost/live/webcam

# Ubuntu/Linux
ffmpeg -f v4l2 -framerate 30 \
  -video_size 1280x720 -i /dev/video0 \
  -c:v libx264 -preset veryfast -b:v 2000k \
  -c:a aac -f flv rtmp://localhost/live/webcam
```

### Screen Capture Stream

```bash
# macOS screen capture to RTMP
ffmpeg -f avfoundation -framerate 30 \
  -capture_cursor 1 -capture_mouse_clicks 1 \
  -pixel_format uyvy422 -i "1:none" \
  -c:v libx264 -preset veryfast -b:v 2000k \
  -c:a aac -f flv rtmp://localhost/live/screenshare
```

## Playback Options

### VLC Player

```
Open network stream: rtmp://localhost/live/loopedstream
```

### ffplay (included with ffmpeg)

```bash
# RTMP
ffplay rtmp://localhost/live/loopedstream

# HLS
ffplay http://localhost:8888/loopedstream/hls.m3u8
```

### Web Browser (HLS)

Open in browser:

```
http://localhost:8888/loopedstream/hls.m3u8
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using RTMP port (1935)
lsof -i :1935

# Kill the process
kill -9 <PID>
```

### Low Latency Streaming

For ultra-low latency (under 1 second):

```bash
ffmpeg -re -stream_loop -1 -i video.mp4 \
  -c:v libx264 \
  -preset ultrafast \
  -tune zerolatency \
  -x264-params "keyint=30:min-keyint=30:scenecut=0" \
  -g 30 \
  -b:v 2000k \
  -maxrate 2000k \
  -bufsize 1000k \
  -c:a aac \
  -b:a 128k \
  -f flv \
  rtmp://localhost/live/mystream
```

### Check Stream Status

```bash
# MediaMTX web interface
curl http://localhost:9997/metrics

# Or open in browser
open http://localhost:9997/metrics
```

## Advanced Examples

### Multiple Streams

Stream to multiple RTMP servers:

```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -c:a aac \
  -f tee \
  "[f=flv]rtmp://localhost/live/stream1 | [f=flv]rtmp://localhost/live/stream2"
```

### Re-encode for Different Bitrates

```bash
# High quality (4000k)
ffmpeg -re -i input.mp4 -c:v libx264 -b:v 4000k \
  -c:a aac -b:a 128k -f flv rtmp://localhost/live/hd

# Medium quality (2000k)
ffmpeg -re -i input.mp4 -c:v libx264 -b:v 2000k \
  -c:a aac -b:a 96k -f flv rtmp://localhost/live/sd
```

## Security

### Secure RTMP (RTMPS)

Enable SSL in MediaMTX configuration:

```yaml
rtmps:
  port: 19350
  certificate: "./mediamtx.pub"
  privateKey: "./mediamtx.key"
```

Generate certificates:

```bash
openssl genrsa -out mediamtx.key 2048
openssl req -new -x509 -key mediamtx.key -out mediamtx.pub -days 365
```

## Monitoring

### Log Analysis

```bash
# Follow MediaMTX logs
tail -f mediamtx.log

# Check active streams
curl http://localhost:9997/metrics | grep streams
```

## Integration Examples

### Stream to YouTube Live

```bash
ffmpeg -re -i input.mp4 \
  -c:v libx264 -c:a aac \
  -f flv rtmp://a.rtmp.youtube.com/live2/STREAM_KEY
```

### Stream to Facebook Live

```bash
ffmpeg -re -i input.mp4 \
  -c:v libx264 -c:a aac \
  -f flv rtmp://rtmp-api.facebook.com/rtmp/STREAM_KEY
```

## References

- [MediaMTX Documentation](https://github.com/bluenviron/mediamtx)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [RTMP Specification](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol)
