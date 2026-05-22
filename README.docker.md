# osTicket Docker Deployment Guide

This guide explains how to run osTicket within Docker containers.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum
- 10GB disk space

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/osTicket/osTicket
   cd osTicket
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your secure passwords
   ```

3. **Build and start containers:**
   ```bash
   docker-compose up -d --build
   ```

4. **Access osTicket installer:**
   Open your browser and navigate to `http://localhost` (or the port you configured in `.env`)

5. **Complete installation:**
   Follow the on-screen osTicket installer wizard to configure your support desk.

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `osticket_root_pass` |
| `MYSQL_DATABASE` | Database name | `osticket` |
| `MYSQL_USER` | Database user | `osticket` |
| `MYSQL_PASSWORD` | Database password | `osticket_pass` |
| `WEB_PORT` | HTTP port | `80` |
| `WEB_SSL_PORT` | HTTPS port | `443` |

### Database Connection (Manual Install)

During the osTicket web installer, use these values:

- **MySQL Host:** `osticket-db`
- **MySQL Database:** `osticket` (or your configured name)
- **MySQL User:** `osticket` (or your configured user)
- **MySQL Password:** (your configured password)

## Management Commands

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs -f

# Rebuild after code changes
docker-compose up -d --build

# Access container shell
docker exec -it osticket-web /bin/bash

# Access MySQL
docker exec -it osticket-db mysql -uosticket -p
```

## Data Persistence

Docker volumes are used to persist data:

| Volume | Purpose |
|--------|---------|
| `osticket-db-data` | MySQL database files |
| `osticket-uploads` | Uploaded attachments |

**Important:** Volumes must be manually deleted to reset data:
```bash
docker-compose down -v
```

## Directory Structure

```
osTicket/
├── Dockerfile              # Web container image
├── docker-compose.yml      # Service definitions
├── docker-entrypoint.sh    # Container startup script
├── .env.example           # Environment template
├── .env                   # Your configuration (create from example)
└── .dockerignore          # Build exclusions
```

## Container Architecture

```
┌─────────────┐      ┌─────────────┐
│   Browser   │──────│ Apache/PHP  │
└─────────────┘      │  (osticket  │
                     │   -web)     │
                     └──────┬──────┘
                            │ MySQL
                     ┌──────┴──────┐
                     │   MySQL 8   │
                     │  (osticket  │
                     │   -db)      │
                     └─────────────┘
```

## Security Notes

1. **Change default passwords** in `.env` before deployment
2. **Use HTTPS** in production by mounting SSL certificates
3. **Restrict network access** to the database container
4. **Keep osTicket updated** for security patches

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Verify .env file exists and has correct format
cat .env
```

### Database connection errors
```bash
# Ensure database is healthy
docker-compose ps

# Wait for database to be ready
docker-compose logs osticket-db
```

### Permission issues
```bash
# Fix permissions by restarting
docker-compose down
docker-compose up -d
```

## SSL/HTTPS Setup (Production)

To enable HTTPS, modify `docker-compose.yml` to mount SSL certificates:

```yaml
osticket-web:
  # ... existing config ...
  volumes:
    - ./ssl/cert.pem:/etc/ssl/certs/ssl-cert.pem:ro
    - ./ssl/key.pem:/etc/ssl/private/ssl-cert-key.pem:ro
```

And configure Apache to use them in a custom virtual host configuration.

## Support

- [osTicket Documentation](https://docs.osticket.com/)
- [Docker Documentation](https://docs.docker.com/)