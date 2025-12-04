# Use NVIDIA PyTorch container (supports sm_120)
FROM nvcr.io/nvidia/pytorch:25.06-py3

# Set frontend to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 libglib2.0-0 \
    libsm6 libxext6 libxrender-dev \
    && rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip

# Install dependencies (PyTorch is already in base image)
RUN pip install -r requirements.txt

# Copy app code
COPY . /app

# Create temp_uploads directory
RUN mkdir -p temp_uploads

# Expose port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]