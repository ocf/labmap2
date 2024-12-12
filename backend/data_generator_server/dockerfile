FROM rust:latest AS builder

WORKDIR /app

COPY ./Cargo.toml ./Cargo.lock ./
COPY ./src ./src

RUN cargo build --release

FROM python:3.9-slim

WORKDIR /app

COPY data_generator.py .

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY --from=builder /app/target/release/data_generator_server ./data_generator_server

ENV RUST_BACKTRACE=1

EXPOSE 8081

CMD ["./data_generator_server"]

