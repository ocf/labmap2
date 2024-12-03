## Instructions

    docker build -t data_generator_server:latest .
    docker run --env-file .env -p 8080:8080 data_generator_server:latest
