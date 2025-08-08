#!/bin/bash

# Docker Hub Publishing Script
# Usage: ./publish.sh yourusername [version]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <docker-hub-username> [version]"
    echo "Example: $0 myusername 1.0.0"
    exit 1
fi

USERNAME=$1
VERSION=${2:-latest}
IMAGE_NAME="codeql-sarif-downloader"
FULL_IMAGE_NAME="$USERNAME/$IMAGE_NAME"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME:latest" .

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Tagging image for Docker Hub..."
docker tag "$IMAGE_NAME:latest" "$FULL_IMAGE_NAME:latest"

if [ "$VERSION" != "latest" ]; then
    docker tag "$IMAGE_NAME:latest" "$FULL_IMAGE_NAME:$VERSION"
    echo "Also tagged as version: $VERSION"
fi

echo "Pushing to Docker Hub..."
docker push "$FULL_IMAGE_NAME:latest"

if [ "$VERSION" != "latest" ]; then
    docker push "$FULL_IMAGE_NAME:$VERSION"
fi

if [ $? -eq 0 ]; then
    echo "Successfully published to Docker Hub!"
    echo "Image available at: https://hub.docker.com/r/$FULL_IMAGE_NAME"
    echo ""
    echo "Users can now run it with:"
    echo "docker run --rm -it -e GITHUB_PAT=\"token\" -v \"\$(pwd)/sarif_downloads:/app/sarif_downloads\" $FULL_IMAGE_NAME"
else
    echo "Push failed!"
    exit 1
fi
