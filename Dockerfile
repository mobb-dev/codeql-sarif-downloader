FROM python:3.11-slim

# Set metadata
LABEL maintainer="mobb-dev"
LABEL description="CodeQL SARIF Downloader - Download and combine CodeQL security scan results from GitHub"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application files
COPY generate_sarif_from_github_codeql.py .
COPY config.json .

# Create output directory and set permissions
RUN mkdir -p /app/sarif_downloads && \
    chmod 755 /app/sarif_downloads

# Create non-root user for security
RUN useradd -m -u 1000 codeql && \
    chown -R codeql:codeql /app
USER codeql

# Set the entrypoint
ENTRYPOINT ["python", "generate_sarif_from_github_codeql.py"]
