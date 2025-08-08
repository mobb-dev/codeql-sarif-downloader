# Docker Hub Publishing Script
# Usage: .\publish.ps1 -Username "yourusername" -Version "1.0.0"

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "latest"
)

$ImageName = "codeql-sarif-downloader"
$FullImageName = "$Username/$ImageName"

Write-Host "Building Docker image..." -ForegroundColor Blue
docker build -t "$ImageName`:latest" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Tagging image for Docker Hub..." -ForegroundColor Blue
docker tag "$ImageName`:latest" "$FullImageName`:latest"

if ($Version -ne "latest") {
    docker tag "$ImageName`:latest" "$FullImageName`:$Version"
    Write-Host "Also tagged as version: $Version" -ForegroundColor Green
}

Write-Host "Pushing to Docker Hub..." -ForegroundColor Blue
docker push "$FullImageName`:latest"

if ($Version -ne "latest") {
    docker push "$FullImageName`:$Version"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully published to Docker Hub!" -ForegroundColor Green
    Write-Host "Image available at: https://hub.docker.com/r/$FullImageName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Users can now run it with:" -ForegroundColor Yellow
    Write-Host "docker run --rm -it -e GITHUB_PAT=`"token`" -v `"`$(pwd)/sarif_downloads:/app/sarif_downloads`" $FullImageName" -ForegroundColor White
} else {
    Write-Host "Push failed!" -ForegroundColor Red
    exit 1
}
