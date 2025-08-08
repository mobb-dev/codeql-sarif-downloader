# CodeQL SARIF Downloader - Docker Wrapper Script (PowerShell)
# Usage: .\run.ps1

# Check if GITHUB_PAT is set
if (-not $env:GITHUB_PAT) {
    Write-Host "Error: GITHUB_PAT environment variable is not set" -ForegroundColor Red
    Write-Host "Please set it with: `$env:GITHUB_PAT = 'your_token_here'" -ForegroundColor Yellow
    exit 1
}

# Build the Docker image if it doesn't exist
$imageExists = docker image inspect codeql-sarif-downloader:latest 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Building Docker image..." -ForegroundColor Blue
    docker build -t codeql-sarif-downloader:latest .
}

# Create sarif_downloads directory if it doesn't exist
if (-not (Test-Path "sarif_downloads")) {
    New-Item -ItemType Directory -Path "sarif_downloads" | Out-Null
}

# Run the container with current directory mounted for output
docker run --rm -it `
    -e GITHUB_PAT="$env:GITHUB_PAT" `
    -v "${PWD}/sarif_downloads:/app/sarif_downloads" `
    codeql-sarif-downloader:latest
