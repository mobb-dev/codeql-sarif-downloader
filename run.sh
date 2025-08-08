#!/bin/bash

# CodeQL SARIF Downloader - Docker Wrapper Script
# Usage: ./run.sh

# Check if GITHUB_PAT is set
if [ -z "$GITHUB_PAT" ]; then
    echo "Error: GITHUB_PAT environment variable is not set"
    echo "Please set it with: export GITHUB_PAT=your_token_here"
    exit 1
fi

# Build the Docker image if it doesn't exist
if ! docker image inspect codeql-sarif-downloader:latest >/dev/null 2>&1; then
    echo "Building Docker image..."
    docker build -t codeql-sarif-downloader:latest .
fi

# Run the container with current directory mounted for output
docker run --rm -it \
    -e GITHUB_PAT="$GITHUB_PAT" \
    -v "$(pwd)/sarif_downloads:/app/sarif_downloads" \
    codeql-sarif-downloader:latest
