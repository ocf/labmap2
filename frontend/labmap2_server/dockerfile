FROM rust:latest AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock Labmap2.html ./
COPY src ./src
COPY static ./static

RUN cargo build --release

ENV RUST_BACKTRACE=1

EXPOSE 8080

CMD ["./target/release/labmap2_server"]
