FROM rust:alpine AS serverbuilder

# TODO: build dependencies and labmap2_server in different layers
WORKDIR /build
COPY ./labmap2_server /build
RUN cargo build --release


FROM debian AS godotbuilder

WORKDIR /build
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip zip ca-certificates libfontconfig
RUN wget -qO godot.zip 'https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip' && \
    wget -qO templ.tpz 'https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz' && \
    unzip godot.zip && mv Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot && \
    mkdir -p ~/.local/share/godot/export_templates && \
    unzip -j templ.tpz 'templates/*' -d ~/.local/share/godot/export_templates/4.3.stable && \
    rm godot.zip templ.tpz

COPY ./labmap2 /build
RUN mkdir static && godot -v --headless --import --export-release Web

FROM alpine

WORKDIR /app
COPY --from=serverbuilder /build/target/release/labmap2_server /app
COPY --from=godotbuilder  /build/static /app/static

ENV RUST_BACKTRACE=1
EXPOSE 8080

CMD ["./labmap2_server"]
