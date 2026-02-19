{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.godotPackages_4_3.godot ];
          shellHook = ''
            git_root="$(git rev-parse --show-toplevel)"
            godot_proj_dir="$git_root/frontend/labmap2"
            ${pkgs.godotPackages_4_3.godot}/bin/godot --path "$godot_proj_dir" -e &
          '';
        };
      });
}
