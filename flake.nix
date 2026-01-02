{
  description = "sv-tutorial local commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.writeShellApplication {
            name = "svt-hello";
            text = ''
              echo "sv-tutorial local command"
            '';
          };

          svt-sim = pkgs.writeShellApplication {
            name = "svt-sim";
            runtimeInputs = [
              pkgs.verilator
              pkgs.gcc
              pkgs.gnumake
              pkgs.git
            ];
            text = ''
              set -euo pipefail

              if [ "$#" -ne 1 ]; then
                echo "usage: svt-sim <top-module>" >&2
                exit 2
              fi

              top_module="$1"

              root="${SVT_ROOT:-$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)}"
              if [ -z "$root" ]; then
                echo "svt-sim: cannot detect repo root. Set SVT_ROOT." >&2
                exit 2
              fi

              build_dir="$root/build/verilator-$top_module"
              mkdir -p "$build_dir"

              verilator \
                --binary \
                --timing \
                --top-module "$top_module" \
                --Mdir "$build_dir" \
                -I"$root/rtl" \
                -I"$root/tb" \
                "$root/rtl"/*.sv \
                "$root/tb"/*.sv

              "$build_dir/V$top_module"
            '';
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/svt-hello";
        };
        svt-sim = {
          type = "app";
          program = "${self.packages.${system}.svt-sim}/bin/svt-sim";
        };
      });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.iverilog
              pkgs.vvp
              pkgs.ripgrep
            ];
          };
        });
    };
}
