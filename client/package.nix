{ stdenvNoCC, godotPackages_4_3 }:

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
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    mkdir -p $HOME/.local/share/godot
    ln -s ${godotTemplates}/share/godot/export_templates $HOME/.local/share/godot

    mkdir -p static
    godot -v --headless --import --export-release Web

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${name}
    cp static/* $out/share/${name}/

    runHook postInstall
  '';
}
