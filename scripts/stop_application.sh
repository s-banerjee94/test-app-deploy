#!/bin/bash

# Stop Spring Boot application
echo "Stopping Spring Boot application..."

APP_DIR="/opt/spring-app"
PID_FILE="$APP_DIR/application.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)

    if ps -p $PID > /dev/null; then
        echo "Stopping application with PID $PID"
        kill $PID

        # Wait for graceful shutdown
        sleep 10

        # Force kill if still running
        if ps -p $PID > /dev/null; then
            echo "Force killing application with PID $PID"
            kill -9 $PID
        fi

        rm -f $PID_FILE
        echo "Application stopped successfully"
    else
        echo "Application with PID $PID is not running"
        rm -f $PID_FILE
    fi
else
    echo "PID file not found, application may not be running"
fi

# Kill any remaining Java processes running our jar (failsafe)
pkill -f "test-app.jar" || true

exit 0