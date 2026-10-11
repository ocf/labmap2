{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          client = pkgs.callPackage ./client/package.nix {};
        };

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.godotPackages_4_3.godot ];
          shellHook = ''
            git_root="$(git rev-parse --show-toplevel)"
            godot_proj_dir="$git_root/client"
            ${pkgs.godotPackages_4_3.godot}/bin/godot --path "$godot_proj_dir" -e &
          '';
        };
      });
}
