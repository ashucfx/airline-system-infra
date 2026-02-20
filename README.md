# 🛫 Airline Management System - Infrastructure

> **Production-ready Docker orchestration for microservices-based airline management platform**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-v3.8-blue)](https://docs.docker.com/compose/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)](https://www.mysql.com/)
[![RabbitMQ](https://img.shields.io/badge/RabbitMQ-3.12-orange?logo=rabbitmq)](https://www.rabbitmq.com/)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Services](#services)
- [Configuration](#configuration)
- [Usage](#usage)
- [Scaling](#scaling)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## 🌟 Overview

This repository contains the complete infrastructure orchestration for the Airline Management System, including:

- **5 Services**: Frontend (Next.js), API Gateway, Flights, Booking, Notification
- **Database**: MySQL 8.0 for persistent storage
- **Message Broker**: RabbitMQ for asynchronous communication
- **Networking**: Isolated bridge network for service communication
- **Volumes**: Persistent data storage for MySQL and RabbitMQ

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Frontend - Next.js (Port 3002)                │
│  • Authentication UI  • Dashboard  • Flight Management      │
│  • Booking Interface  • Admin Panel  • Analytics            │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ↓
┌───────────────────────────────────────────────────────────────┐
│                  API Gateway (Port 8000)                       │
│  • JWT Authentication  • Rate Limiting  • Service Routing     │
└────────────┬──────────────────────────────┬───────────────────┘
             │                               │
             ↓                               ↓
    ┌────────────────┐            ┌─────────────────────┐
    │ Flights Service│            │  Booking Service    │
    │   (Port 3000)  │←───────────│    (Port 3001)      │
    │                │            │                     │
    │ • Airplanes    │            │ • Reservations      │
    │ • Airports     │            │ • Payments          │
    │ • Cities       │            │ • Cron Jobs         │
    │ • Flights      │            └──────────┬──────────┘
    │ • Seats        │                       │
    └────────┬───────┘                       │
             │                               │
             └───────────┬───────────────────┘
                         ↓
                 ┌───────────────┐
                 │   MySQL 8.0   │
                 │  (Port 3306)  │
                 │               │
                 │ • Flights DB  │
                 │ • Gateway DB  │
                 │ • Notify DB   │
                 └───────────────┘
                         
         ┌───────────────────────────┐
         │    RabbitMQ 3.12          │
         │    (Port 5672/15672)      │
         │                           │
         │  Queue: noti-queue        │
         └────────┬──────────────────┘
                  │
                  ↓
         ┌────────────────────┐
         │ Notification Service│
         │    (Port 4000)      │
         │                    │
         │ • Email (Gmail)    │
         │ • Queue Consumer   │
         └────────────────────┘
```

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker**: v20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose**: v2.0+ ([Install Docker Compose](https://docs.docker.com/compose/install/))
- **Git**: Latest version
- **Minimum System Requirements**:
  - RAM: 4GB (8GB recommended)
  - Disk Space: 10GB free
  - CPU: 2 cores (4 cores recommended)

### Verify Installation

```bash
docker --version
docker-compose --version
```

## 🚀 Quick Start

### 1. Clone All Repositories

```bash
# Clone infrastructure repository
git clone https://github.com/ashucfx/airline-system-infra.git
cd airline-system-infra

# Clone service repositories (place them as siblings to this infra repo)
cd ..
git clone https://github.com/ashucfx/Flights-Service.git Flights
git clone https://github.com/ashucfx/Airline-Notification-Service.git Noti-Service
git clone https://github.com/ashucfx/Flight-Booking-Service.git Flights-Booking-Service
git clone https://github.com/ashucfx/API-Gateway-Flights.git API-Gateway
```

**Expected Directory Structure:**
```
Airline Management System/
├── airline-system-infra/         # This repository
├── Flights/                       # Flights Service
├── Noti-Service/                  # Notification Service
├── Flights-Booking-Service/       # Booking Service
└── API-Gateway/                   # API Gateway
```

### 2. Configure Environment Variables

```bash
cd airline-system-infra
cp .env.example .env
```

**Edit `.env` file and update:**
- Database passwords
- JWT secret (minimum 32 characters)
- Gmail credentials (use App Password)
- RabbitMQ credentials

### 3. Start All Services

```bash
# Start all services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Check service health
docker-compose ps
```

### 4. Initialize Databases

```bash
# Run migrations for each service
docker-compose exec flights-service npm run migrate
docker-compose exec booking-service npm run migrate
docker-compose exec notification-service npm run migrate
docker-compose exec api-gateway npm run migrate
```

### 5. Access Services

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:3002 | Web application UI |
| **API Gateway** | http://localhost:8000 | Main entry point |
| **Flights Service** | http://localhost:3000 | Flight management |
| **Booking Service** | http://localhost:3001 | Booking operations |
| **Notification Service** | http://localhost:4000 | Email notifications |
| **RabbitMQ Management** | http://localhost:15672 | Queue monitoring |
| **Health Checks** | http://localhost:PORT/health | Service status |

**Default Credentials:**
- Frontend Login: `admin@airline.com` / `admin123`
- RabbitMQ: `airline_user` / (from .env)

## 🎯 Services

### Frontend (Port 3002)
- **Purpose**: User interface for airline management
- **Technology**: Next.js 16, React 19, TypeScript, Tailwind CSS
- **Dependencies**: API Gateway, Flights Service, Booking Service
- **Features**: 
  - JWT authentication with login/logout
  - Dashboard with real-time statistics
  - Flight management interface
  - Booking management interface
  - Responsive design
  - Health check endpoint
- **Repository**: [airline-frontend](https://github.com/ashucfx/airline-frontend)

### API Gateway (Port 8000)
- **Purpose**: Authentication, routing, rate limiting
- **Dependencies**: MySQL, Flights Service, Booking Service
- **Features**: JWT auth, role-based access, request proxying

### Flights Service (Port 3000)
- **Purpose**: Manage flights, airports, cities, airplanes
- **Dependencies**: MySQL
- **Features**: CRUD operations, search, filtering

### Booking Service (Port 3001)
- **Purpose**: Handle flight reservations and bookings
- **Dependencies**: MySQL, RabbitMQ, Flights Service
- **Features**: Booking management, cron jobs, notifications

### Notification Service (Port 4000)
- **Purpose**: Send email notifications
- **Dependencies**: MySQL, RabbitMQ, Gmail SMTP
- **Features**: Queue consumer, email delivery

### MySQL (Port 3306)
- **Purpose**: Persistent data storage
- **Databases**: Flights, api_gateway, notification_db
- **Features**: Health checks, data persistence

### RabbitMQ (Port 5672/15672)
- **Purpose**: Message queue for async communication
- **Features**: Management UI, persistent queues

## ⚙️ Configuration

### Environment Variables

All configuration is managed through `.env` file. See `.env.example` for complete list.

**Critical Variables:**
- `JWT_SECRET`: Must be 32+ characters
- `MYSQL_ROOT_PASSWORD`: Strong password
- `GMAIL_PASS`: Gmail App Password (not regular password)

### Custom Ports

Modify port mappings in `.env`:
```env
API_GATEWAY_PORT=8000
FLIGHTS_SERVICE_PORT=3000
BOOKING_SERVICE_PORT=3001
NOTIFICATION_SERVICE_PORT=4000
```

### CORS Configuration

For production, set specific origins:
```env
CORS_ORIGIN=https://yourdomain.com,https://app.yourdomain.com
```

## 💻 Usage

### Start System

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d api-gateway

# Start with build (if code changed)
docker-compose up -d --build
```

### Stop System

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api-gateway

# Last 100 lines
docker-compose logs --tail=100 flights-service
```

### Service Management

```bash
# Restart service
docker-compose restart booking-service

# Check status
docker-compose ps

# Execute command in container
docker-compose exec api-gateway npm run migrate
```

## 📊 Scaling

### Horizontal Scaling

Scale individual services:

```bash
# Scale booking service to 3 instances
docker-compose up -d --scale booking-service=3

# Scale flights service to 2 instances
docker-compose up -d --scale flights-service=2
```

**Note**: Remove port mappings for scaled services or use dynamic ports.

### Load Balancing

For production, add a load balancer (nginx/traefik):

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

## 📡 Monitoring

### Health Checks

All services include health checks:

```bash
# Check health via Docker
docker-compose ps

# Check health via HTTP
curl http://localhost:8000/health
curl http://localhost:3000/health
curl http://localhost:3001/health
curl http://localhost:4000/health
```

### RabbitMQ Management

Access RabbitMQ Management UI:
- URL: http://localhost:15672
- Username: From `RABBITMQ_USER` in .env
- Password: From `RABBITMQ_PASS` in .env

### Database Access

```bash
# MySQL CLI access
docker-compose exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD}

# Show databases
docker-compose exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;"
```

## 🔍 Troubleshooting

### Common Issues

**1. Services won't start**
```bash
# Check logs
docker-compose logs

# Verify environment variables
cat .env

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

**2. Database connection errors**
```bash
# Wait for MySQL to be fully ready
docker-compose exec mysql mysqladmin ping -h localhost

# Check MySQL health
docker-compose ps mysql
```

**3. RabbitMQ connection errors**
```bash
# Check RabbitMQ status
docker-compose exec rabbitmq rabbitmq-diagnostics status

# View RabbitMQ logs
docker-compose logs rabbitmq
```

**4. Port conflicts**
```bash
# Check if ports are already in use
netstat -ano | findstr :8000  # Windows
lsof -i :8000                  # Mac/Linux

# Change ports in .env file
```

### Reset Everything

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up -d --build
```

## 🔐 Security Best Practices

1. ✅ **Change all default passwords** before production
2. ✅ **Use strong JWT secrets** (32+ characters)
3. ✅ **Configure specific CORS origins** (not *)
4. ✅ **Use environment-specific .env files**
5. ✅ **Never commit .env files** to version control
6. ✅ **Use Gmail App Passwords** (not regular passwords)
7. ✅ **Enable Docker secrets** for production
8. ✅ **Regular security updates** for images

## 📦 Volumes

Persistent data is stored in Docker volumes:

- **mysql_data**: Database files
- **rabbitmq_data**: Queue data

```bash
# List volumes
docker volume ls | grep airline

# Backup MySQL data
docker run --rm -v airline-mysql-data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-backup.tar.gz /data

# Restore MySQL data
docker run --rm -v airline-mysql-data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql-backup.tar.gz -C /
```

## 🌐 Networks

All services communicate via `airline-network` bridge network:

```bash
# Inspect network
docker network inspect airline-network

# View connected containers
docker network ls
```

## 📝 Development Workflow

### Making Changes

```bash
# 1. Make changes to service code
# 2. Rebuild specific service
docker-compose build service-name

# 3. Restart service
docker-compose up -d service-name

# 4. View logs
docker-compose logs -f service-name
```

### Database Migrations

```bash
# Run migrations
docker-compose exec flights-service npx sequelize-cli db:migrate

# Rollback migration
docker-compose exec flights-service npx sequelize-cli db:migrate:undo
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/orchestration-improvement`
3. Commit changes: `git commit -m 'Add new orchestration feature'`
4. Push to branch: `git push origin feature/orchestration-improvement`
5. Open Pull Request

## 📄 License

This project is licensed under the ISC License.

## 👥 Authors

- **Ashutosh Shukla** - [@ashucfx](https://github.com/ashucfx)

## 🔗 Related Repositories

- [API Gateway](https://github.com/ashucfx/API-Gateway-Flights)
- [Flights Service](https://github.com/ashucfx/Flights-Service)
- [Booking Service](https://github.com/ashucfx/Flight-Booking-Service)
- [Notification Service](https://github.com/ashucfx/Airline-Notification-Service)

## 📞 Support

For issues, questions, or contributions, please open an issue in the respective repository.

---

**⚡ Quick Commands Cheat Sheet**

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# Rebuild and start
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Access MySQL
docker-compose exec mysql mysql -uroot -p

# Access RabbitMQ UI
# http://localhost:15672
```

---

Made with ❤️ for scalable microservices architecture
