# AGENTS.md - Hysteria2 Docker Project Guide

This file contains essential information for agentic coding agents working in this repository.

## Project Overview

This is a Hysteria2 proxy server Docker image project. Hysteria2 is a high-performance proxy protocol based on QUIC/UDP with TLS 1.3 encryption and BBR congestion control.

## Build Commands

### Docker Build
```bash
# Build the image
docker build -t hysteria2:latest .

# Build with custom tag
docker build -t hysteria2:v1.0.0 .
```

### Docker Compose
```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Test Commands
```bash
# Test container startup
docker run --rm -p 7777:7777/udp hysteria2:latest

# Test with custom password
docker run --rm -p 7777:7777/udp -e password=test123 hysteria2:latest

# Test with custom port
docker run --rm -p 8888:8888/udp -e HY2_PORT=8888 hysteria2:latest
```

### Lint/Validation
```bash
# Validate Dockerfile syntax
docker build --dry-run .

# Test docker-compose configuration
docker-compose config

# Check for common Docker best practices
hadolint Dockerfile  # if hadolint is available
```

## Code Style Guidelines

### Shell Scripts (start.sh, build scripts)
- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Use 4-space indentation (no tabs)
- Use uppercase for environment variables: `${HY2_PORT}`
- Use lowercase with underscores for local variables: `effective_password`
- Quote variables: `"${VARIABLE}"`
- Use functions for repeated code blocks
- Add comments for complex logic

### Dockerfile
- Use specific base image tags: `FROM tobyxdd/hysteria:latest`
- Combine RUN commands with `&&`
- Use `--no-cache` for apk installs
- Set WORKDIR before COPY
- Use absolute paths: `COPY start.sh /app/start.sh`
- Expose ports with protocol: `EXPOSE 7777/udp`
- Use array syntax for ENTRYPOINT: `ENTRYPOINT ["/app/start.sh"]`

### Docker Compose
- Use version '3.8'
- Specify restart policy: `restart: unless-stopped`
- Include port protocol: `"7777:7777/udp"`
- Use descriptive container names
- Comment optional sections

### File Naming
- Use kebab-case for scripts: `build-and-push.sh`
- Use lowercase for configuration files: `docker-compose.yml`
- Use uppercase for README files: `README.md`, `DEPLOY.md`

### Error Handling
- Check file existence before operations: `if [ ! -f "Dockerfile" ]`
- Validate user input: `if [ -z "$DOCKER_USERNAME" ]`
- Use proper exit codes: `exit 1` for errors
- Provide meaningful error messages

### Security Best Practices
- Never hardcode passwords in scripts
- Use environment variables for sensitive data
- Generate random passwords when not provided
- Use read-only file permissions where appropriate
- Don't log sensitive information

## Project Structure

```
hy2-main/
├── Dockerfile                 # Main image definition
├── docker-compose.yml         # Development deployment
├── start.sh                   # Container entrypoint script
├── build-and-push.sh          # Interactive build script
├── build-and-push-simple.sh   # Quick build script
├── upload-to-github.sh        # GitHub upload helper
├── README.md                  # User documentation
├── DEPLOY.md                  # Deployment guide
├── GITHUB.md                  # GitHub upload guide
└── AGENTS.md                  # This file
```

## Key Components

### start.sh
- Generates Hysteria2 configuration dynamically
- Creates self-signed certificates
- Handles password generation/validation
- Provides user-friendly connection guide
- Optimized QUIC parameters for high-latency networks

### Dockerfile
- Based on official Hysteria2 image
- Installs bash and openssl dependencies
- Copies and makes executable the start script
- Exposes UDP port 7777

### Configuration
- Default port: 7777 (UDP)
- Auto-generates strong passwords if not provided
- Uses Apple.com masquerade for traffic obfuscation
- Configured with multiple DNS resolvers
- BBR congestion control enabled

## Testing Strategy

### Manual Testing
1. Build image: `docker build -t test-hy2 .`
2. Run container: `docker run --rm -p 7777:7777/udp test-hy2`
3. Verify logs show connection information
4. Test with custom password/port combinations

### Automated Testing
- Test script syntax: `bash -n start.sh`
- Validate Dockerfile: `docker build --dry-run .`
- Check docker-compose: `docker-compose config`

## Deployment Notes

- Image supports both Docker Hub and GitHub Container Registry
- Uses semantic versioning: v1.0.0, v1.0.1, etc.
- Always pushes both versioned and latest tags
- Supports multi-architecture builds via GitHub Actions

## Common Issues

1. **Port conflicts**: Ensure UDP port is available
2. **Certificate issues**: Scripts auto-generate self-signed certs
3. **DNS resolution**: Multiple resolvers configured for reliability
4. **Firewall**: Must allow UDP traffic on configured port

## Environment Variables

- `HY2_PORT`: Server listening port (default: 7777)
- `password`: Custom connection password (auto-generated if not set)

## Maintenance

- Update base image regularly: `FROM tobyxdd/hysteria:latest`
- Review QUIC parameters for network optimization
- Keep documentation synchronized with code changes
- Test with different Docker versions