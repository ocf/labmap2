## Instructions

    docker build -t data_generator_server:latest .
    docker run --env-file .env -p 8080:8080 data_generator_server:latest

## Using the API (Example)
Sending a POST /set command to the data generator server updates the list of overwrites, useful for when a device needs a custom status
Statuses can currently be set to "online", "offline", and "out-of-order".

    curl -X POST -H "Content-Type: application/json" -d '{
        "desktops": [
            {
                "name": "tabitha",
                "status": "out-of-order",
                "logged_in": "no",
                "user": "none"
            }
        ]
    }' http://127.0.0.1:8080/set


