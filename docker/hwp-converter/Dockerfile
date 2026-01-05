FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install LibreOffice, fonts, curl, and Python
RUN apt update && apt install -y \
    libreoffice \
    curl \
    fonts-nanum \
    fonts-noto-cjk \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Flask
RUN pip3 install flask werkzeug

# Download and install H2Orestart extension for HWP support
RUN curl -L -o /tmp/H2Orestart.oxt https://github.com/ebandal/H2Orestart/releases/download/v0.7.9/H2Orestart.oxt \
    && unopkg add --shared /tmp/H2Orestart.oxt \
    && rm /tmp/H2Orestart.oxt

WORKDIR /app

# Copy API server
COPY server.py .

# Create work directory
RUN mkdir -p /data/work

EXPOSE 3000

# Run API server
CMD ["python3", "server.py"]
