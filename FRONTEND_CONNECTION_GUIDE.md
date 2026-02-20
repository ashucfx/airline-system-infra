# Frontend-Backend Connection Guide

## Architecture Overview

The frontend connects to backend services through both **external** (browser) and **internal** (Docker network) URLs:

### Browser → Backend (External)
When accessing from your browser at `http://localhost:3002`, API calls use:
- API Gateway: `http://localhost:8000`
- Flights Service: `http://localhost:3000`  
- Booking Service: `http://localhost:3001`

**Why?** The browser runs on your host machine, so it uses `localhost` to reach Docker-exposed ports.

### Frontend Container → Backend (Internal)
Inside Docker network, the Next.js server makes API calls using service names:
- API Gateway: `http://api-gateway:8000`
- Flights Service: `http://flights-service:3000`
- Booking Service: `http://booking-service:3001`

**Why?** Docker's internal DNS resolves service names, avoiding port conflicts and enabling scalability.

## Environment Configuration

### For Local Development (without Docker)

Create `airline-frontend/.env.local`:
```env
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:8000
NEXT_PUBLIC_FLIGHTS_SERVICE_URL=http://localhost:3000
NEXT_PUBLIC_BOOKING_SERVICE_URL=http://localhost:3001
```

### For Docker Deployment (Production)

Environment variables are set in `docker-compose.yml`:
```yaml
environment:
  # Internal Docker network URLs
  NEXT_PUBLIC_API_GATEWAY_URL: http://api-gateway:8000
  NEXT_PUBLIC_FLIGHTS_SERVICE_URL: http://flights-service:3000
  NEXT_PUBLIC_BOOKING_SERVICE_URL: http://booking-service:3001
```

## CORS Configuration

Backend services must allow frontend origin. In `.env`:

```env
# For development (allow all origins)
CORS_ORIGIN=*

# For production (specific origins)
CORS_ORIGIN=http://localhost:3002,https://yourdomain.com
```

All backend services (`API-Gateway`, `Flights`, `Booking`, `Notification`) have CORS enabled via the `CORS_ORIGIN` environment variable.

## Network Flow

```
┌──────────────────────────────────────────────────────────┐
│  Browser (http://localhost:3002)                         │
│  ↓ Makes API calls to localhost:8000/3000/3001          │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ↓ (Host network - exposed ports)
┌────────────────────────────────────────────────────────────┐
│  Docker Host (Port Mappings)                               │
│  • 3002:3000 → frontend container                          │
│  • 8000:8000 → api-gateway container                       │
│  • 3000:3000 → flights-service container                   │
│  • 3001:3001 → booking-service container                   │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ↓ (Bridge network - internal DNS)
┌────────────────────────────────────────────────────────────┐
│  airline-network (Bridge)                                  │
│                                                            │
│  ┌────────────┐    ┌─────────────┐    ┌────────────────┐ │
│  │  frontend  │───▶│ api-gateway │───▶│ flights-service│ │
│  │  (Next.js) │    │  (Express)  │    │   (Express)    │ │
│  └────────────┘    └─────────────┘    └────────────────┘ │
│                            │                               │
│                            ▼                               │
│                    ┌────────────────┐                      │
│                    │booking-service │                      │
│                    │   (Express)    │                      │
│                    └────────────────┘                      │
│                            │                               │
│                            ▼                               │
│                    ┌────────────────┐                      │
│                    │     MySQL      │                      │
│                    │   RabbitMQ     │                      │
│                    └────────────────┘                      │
└────────────────────────────────────────────────────────────┘
```

## Testing Connection

### 1. Start All Services

```bash
cd airline-system-infra
docker-compose up -d
```

### 2. Check Service Health

```bash
# Frontend
curl http://localhost:3002/api/health

# API Gateway
curl http://localhost:8000/health

# Flights Service
curl http://localhost:3000/health

# Booking Service
curl http://localhost:3001/health
```

Expected response for all:
```json
{
  "status": "ok",
  "service": "service-name",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### 3. Test Frontend Access

Open browser:
```
http://localhost:3002
```

Should redirect to login page. Use credentials:
- Email: `admin@airline.com`
- Password: `admin123`

### 4. Verify API Connectivity

After login, check browser DevTools Network tab:
- API calls should go to `http://localhost:8000/api/v1/...`
- Responses should return 200 OK with data
- Authorization headers should include JWT token

### 5. Check Docker Logs

```bash
# View frontend logs
docker-compose logs -f frontend

# View all service logs
docker-compose logs -f
```

Look for:
- ✅ "Server running on port 3000" (frontend)
- ✅ "Connected to MySQL" (backend services)
- ✅ "Connected to RabbitMQ" (booking/notification)
- ❌ CORS errors (if present, check CORS_ORIGIN)
- ❌ Connection refused (check service dependencies)

## Common Issues & Solutions

### Issue 1: CORS Errors
**Symptom:** Browser console shows CORS policy errors

**Solution:**
```bash
# Edit airline-system-infra/.env
CORS_ORIGIN=http://localhost:3002

# Restart services
docker-compose restart api-gateway flights-service booking-service
```

### Issue 2: API Gateway 502 Bad Gateway
**Symptom:** Frontend can't reach API Gateway

**Solution:**
```bash
# Check if api-gateway is running
docker-compose ps api-gateway

# Check health
curl http://localhost:8000/health

# View logs
docker-compose logs api-gateway

# Restart if needed
docker-compose restart api-gateway
```

### Issue 3: Connection Refused
**Symptom:** Frontend shows "Network Error" or "Connection refused"

**Solution:**
```bash
# Ensure all services are healthy
docker-compose ps

# Check if ports are exposed
docker-compose port api-gateway 8000
docker-compose port flights-service 3000
docker-compose port booking-service 3001

# Restart entire stack
docker-compose down
docker-compose up -d
```

### Issue 4: JWT Token Errors
**Symptom:** Login fails or 401 Unauthorized

**Solution:**
```bash
# Verify JWT_SECRET is set
echo $JWT_SECRET  # or check .env file

# Clear browser localStorage
# Open DevTools > Application > Local Storage > Clear

# Restart API Gateway
docker-compose restart api-gateway
```

### Issue 5: Frontend Shows Blank Page
**Symptom:** http://localhost:3002 loads but shows nothing

**Solution:**
```bash
# Check frontend logs
docker-compose logs frontend

# Verify build succeeded
docker-compose build frontend

# Check if frontend is healthy
curl http://localhost:3002/api/health

# Restart frontend
docker-compose restart frontend
```

## Environment Variables Summary

### Backend Services (.env in airline-system-infra)
```env
# Expose services to host
API_GATEWAY_PORT=8000
FLIGHTS_SERVICE_PORT=3000
BOOKING_SERVICE_PORT=3001
FRONTEND_PORT=3002

# Allow frontend origin
CORS_ORIGIN=http://localhost:3002

# JWT secret for authentication
JWT_SECRET=your_32_character_secret_key_here
```

### Frontend (set in docker-compose.yml)
```yaml
environment:
  # Internal Docker URLs (container-to-container)
  NEXT_PUBLIC_API_GATEWAY_URL: http://api-gateway:8000
  NEXT_PUBLIC_FLIGHTS_SERVICE_URL: http://flights-service:3000
  NEXT_PUBLIC_BOOKING_SERVICE_URL: http://booking-service:3001
```

## Debug Commands

```bash
# Check network connectivity between containers
docker-compose exec frontend ping api-gateway
docker-compose exec frontend wget -qO- http://api-gateway:8000/health

# Inspect bridge network
docker network inspect airline-network

# View environment variables
docker-compose exec frontend env | grep NEXT_PUBLIC

# Execute commands inside containers
docker-compose exec frontend sh
docker-compose exec api-gateway sh

# Monitor real-time logs
docker-compose logs -f --tail=100 frontend api-gateway flights-service
```

## Success Indicators

When everything is working correctly:

1. ✅ All services show `Up (healthy)` in `docker-compose ps`
2. ✅ Frontend loads at http://localhost:3002
3. ✅ Login works with demo credentials
4. ✅ Dashboard shows statistics (flights, bookings, airplanes)
5. ✅ Flight management page loads data
6. ✅ Booking management page loads data
7. ✅ Browser DevTools Network tab shows successful API calls
8. ✅ No CORS errors in browser console
9. ✅ Health endpoints return 200 OK for all services
10. ✅ Docker logs show no connection errors

## Production Considerations

For production deployment:

1. **Use specific CORS origins:**
   ```env
   CORS_ORIGIN=https://yourdomain.com,https://app.yourdomain.com
   ```

2. **Update frontend environment for external URLs:**
   ```yaml
   NEXT_PUBLIC_API_GATEWAY_URL: https://api.yourdomain.com
   ```

3. **Enable HTTPS:**
   - Use reverse proxy (Nginx/Traefik)
   - Configure SSL certificates
   - Update all URLs to use https://

4. **Secure secrets:**
   - Use Docker secrets or external secret management
   - Never commit .env files
   - Rotate JWT_SECRET regularly

5. **Monitor health:**
   - Set up health check monitoring
   - Configure alerting for service failures
   - Use logging aggregation (ELK, Splunk)
