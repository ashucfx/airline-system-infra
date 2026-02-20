# Airline Management System - Start Script (PowerShell)

Write-Host "🛫 Starting Airline Management System..." -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (!(Test-Path .env)) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "📝 Please copy .env.example to .env and configure it" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.example .env" -ForegroundColor Yellow
    exit 1
}

# Start services
Write-Host "🚀 Starting all services..." -ForegroundColor Green
docker-compose up -d

Write-Host ""
Write-Host "⏳ Waiting for services to be healthy..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check status
docker-compose ps

Write-Host ""
Write-Host "✅ Services started!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Access points:" -ForegroundColor Cyan
Write-Host "   API Gateway:       http://localhost:8000"
Write-Host "   Flights Service:   http://localhost:3000"
Write-Host "   Booking Service:   http://localhost:3001"
Write-Host "   Notify Service:    http://localhost:4000"
Write-Host "   RabbitMQ UI:       http://localhost:15672"
Write-Host ""
Write-Host "📊 View logs:         docker-compose logs -f" -ForegroundColor Yellow
Write-Host "🛑 Stop system:       docker-compose down" -ForegroundColor Yellow
