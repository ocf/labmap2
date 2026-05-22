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

# pre-compress assets
RUN mkdir static && \
    godot -v --headless --import --export-release Web && \
    find static -type f \
         \( -name '*.wasm' -o -name '*.js' -o -name '*.html' -o -name '*.pck' \) \
        -exec brotli --best --keep {} \; \
        -exec gzip --best --keep {} \;

FROM caddy:alpine

WORKDIR /app
COPY --from=godotbuilder  /build/static /app/static

EXPOSE 8080
