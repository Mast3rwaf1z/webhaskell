{ pkgs, self, system, ... }:

let
    env = pkgs.haskellPackages.ghcWithPackages (hs: with hs; [
        self.packages.${system}.default
    ] ++ self.packages.${system}.default.buildInputs);
in

pkgs.writeShellScriptBin "repl" ''
    ${env}/bin/ghci
''
