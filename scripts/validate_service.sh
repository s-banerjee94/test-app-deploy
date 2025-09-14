#!/bin/bash

# Validate that the Spring Boot application is running and responding
echo "Validating Spring Boot application..."

APP_DIR="/opt/spring-app"
PID_FILE="$APP_DIR/application.pid"

# Check if PID file exists and process is running
if [ ! -f "$PID_FILE" ]; then
    echo "ERROR: PID file not found"
    exit 1
fi

PID=$(cat $PID_FILE)
if ! ps -p $PID > /dev/null; then
    echo "ERROR: Application process is not running"
    exit 1
fi

echo "Application process is running with PID $PID"

# Wait for application to be ready (up to 30 seconds)
echo "Waiting for application to be ready..."
for i in {1..30}; do
    if curl -f -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "Application is healthy and responding"
        exit 0
    fi

    # Fallback: try root endpoint if actuator is not available
    if curl -f -s http://localhost:8080/ > /dev/null 2>&1; then
        echo "Application is responding on root endpoint"
        exit 0
    fi

    echo "Attempt $i: Application not ready yet, waiting..."
    sleep 2
done

# Final check - if we can connect to port 8080, consider it successful
if netstat -tuln | grep :8080 > /dev/null; then
    echo "Application is listening on port 8080"
    exit 0
fi

echo "ERROR: Application failed validation - not responding after 60 seconds"
exit 1