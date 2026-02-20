#!/bin/bash

# Airline Management System - Start Script

echo "🛫 Starting Airline Management System..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📝 Please copy .env.example to .env and configure it"
    echo "   cp .env.example .env"
    exit 1
fi

# Start services
echo "🚀 Starting all services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check status
docker-compose ps

echo ""
echo "✅ Services started!"
echo ""
echo "🌐 Access points:"
echo "   API Gateway:       http://localhost:8000"
echo "   Flights Service:   http://localhost:3000"
echo "   Booking Service:   http://localhost:3001"
echo "   Notify Service:    http://localhost:4000"
echo "   RabbitMQ UI:       http://localhost:15672"
echo ""
echo "📊 View logs:         docker-compose logs -f"
echo "🛑 Stop system:       docker-compose down"
