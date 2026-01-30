#!/bin/bash

# Production Deployment Script for YONECO Mental Health App

set -e

echo "🚀 Starting YONECO Mental Health App Deployment..."

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    echo "❌ Error: .env.production file not found!"
    echo "Please create .env.production with your production settings"
    exit 1
fi

# Load production environment
export $(cat .env.production | xargs)

# Build frontend applications
echo "📦 Building frontend applications..."

# Build admin dashboard
cd admin-dashboard-vue
npm install
npm run build
cd ..

# Build web app
cd yoneco-web
npm install
npm run build
cd ..

# Update requirements if needed
echo "📋 Installing Python dependencies..."
cd python_api
pip install -r requirements.txt
cd ..

# Run database migrations
echo "🗄️ Running database migrations..."
cd python_api
python -c "
import models
from database import engine
models.Base.metadata.create_all(bind=engine)
print('Database tables created successfully')
"
cd ..

# Start services with Docker Compose
echo "🐳 Starting services with Docker Compose..."
docker-compose down
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Health check
echo "🏥 Performing health check..."
if curl -f http://localhost:8000/health; then
    echo "✅ API is healthy"
else
    echo "❌ API health check failed"
    docker-compose logs api
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo "📊 Admin Dashboard: https://admin.yourdomain.com"
echo "🌐 Web App: https://yourdomain.com"
echo "🔧 API: https://yourdomain.com/api"

# Show running containers
docker-compose ps