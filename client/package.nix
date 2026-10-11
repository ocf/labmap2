{
  stdenvNoCC,
  godotPackages_4_3,
  brotli,
  gzip,
  zstd,
}:

let
  godot = godotPackages_4_3.godot;
  godotTemplates = godotPackages_4_3.export-templates-bin;
in
stdenvNoCC.mkDerivation rec {
  name = "labmap2-wasm";
  src = ./.;

  nativeBuildInputs = [
    godot
    godotTemplates
    brotli
    gzip
    zstd
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    mkdir -p $HOME/.local/share/godot
    ln -s ${godotTemplates}/share/godot/export_templates $HOME/.local/share/godot

    mkdir -p static
    godot -v --headless --import --export-release Web

    # pre-compress for web server to serve if client supports it
    find static -type f \
         \( -name '*.wasm' -o -name '*.js' -o -name '*.html' -o -name '*.pck' \) \
        -exec brotli --best --keep {} \; \
        -exec gzip --best --keep {} \; \
        -exec zstd -19 --keep {} \;

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${name}
    cp static/* $out/share/${name}/

    runHook postInstall
  '';
}
