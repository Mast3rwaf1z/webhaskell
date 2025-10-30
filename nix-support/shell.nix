{ self, system, pkgs, ... }:

pkgs.mkShellNoCC {
    packages = with pkgs; [
        haskell-language-server
        cabal-install
        (haskellPackages.ghcWithPackages self.packages.${system}.default.ghcPackages)
    ];
}
