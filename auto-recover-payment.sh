
#!/bin/bash

CONTAINER="payment-service"
INTERVAL=10

echo "Starting payment service recovery monitor..."

while true; do

    RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)

    if [ "$RUNNING" != "true" ]; then
        echo "$(date): Payment container is stopped. Starting it..."
        docker start "$CONTAINER"

    elif ! docker exec "$CONTAINER" python -c \
        "import urllib.request; urllib.request.urlopen('http://localhost:8001/health', timeout=3)" \
        >/dev/null 2>&1; then

        echo "$(date): Payment health check failed. Restarting..."
        docker restart "$CONTAINER"
    fi

    sleep "$INTERVAL"

done
