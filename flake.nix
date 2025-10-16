{
  description = "Static ARMv7 builder and cross shell for JetKVM";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAll = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
  in {
    devShells = forAll (pkgs: {
      default = pkgs.mkShell { packages = [ pkgs.nix pkgs.git ]; };
    });

    apps = forAll (pkgs:
      let
        host = pkgs.stdenv.hostPlatform.system; # e.g. x86_64-linux
        build = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = [ pkgs.nix ];
          text = ''
            set -euo pipefail
            if [ "$#" -lt 1 ]; then
              echo "usage: build <attr> [-- extra nix build args]"
              echo "example: build hello"
              exit 1
            fi
            PKG="$1"; shift || true
            REF="''${NIXPKGS:-nixpkgs}"

            # Static ARMv7 via the cross set used in 24.05:
            ATTR="''${REF}#legacyPackages.${host}.pkgsCross.armv7l-hf-multiplatform.pkgsStatic.''${PKG}"

            echo ">> nix build ''${ATTR} $*"
            if ! nix build "''${ATTR}" "$@"; then
              echo "Primary attr failed. Trying fallback (unstable musl naming)..." >&2
              FALLBACK="''${REF}#legacyPackages.${host}.pkgsCross.armv7l-hf-multiplatform-musl.pkgsStatic.''${PKG}"
              nix build "''${FALLBACK}" "$@" || {
                echo "Both attempts failed." >&2
                exit 1
              }
            fi

            echo "✔ Done → ./result"
          '';
        };
      in {
        build = { type = "app"; program = "${build}/bin/build"; };
      });
  };
}
