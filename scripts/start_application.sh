#!/bin/bash

# Start Spring Boot application
echo "Starting Spring Boot application..."

# Set Java home if not already set
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto

# Application directory
APP_DIR="/opt/spring-app"
JAR_FILE="$APP_DIR/test-app.jar"
PID_FILE="$APP_DIR/application.pid"

# Check if application is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if ps -p $PID > /dev/null; then
        echo "Application is already running with PID $PID"
        exit 0
    else
        rm -f $PID_FILE
    fi
fi

# Start the application
cd $APP_DIR
nohup $JAVA_HOME/bin/java -jar $JAR_FILE --server.port=8080 > application.log 2>&1 &
echo $! > $PID_FILE

echo "Spring Boot application started with PID $(cat $PID_FILE)"

# Wait a moment and verify the application started
sleep 5
if ps -p $(cat $PID_FILE) > /dev/null; then
    echo "Application successfully started"
    exit 0
else
    echo "Failed to start application"
    exit 1
fi