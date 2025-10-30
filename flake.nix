{
    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
    };
    outputs = { nixpkgs, ... } @ _inputs: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        version = "0.1.0";
        inputs = _inputs // { inherit system pkgs version; };
    in {
        devShells.${system}.default = import ./nix-support/shell.nix inputs;
        packages.${system} = {
            default = import ./nix-support/package.nix inputs;
            repl = import ./nix-support/repl.nix inputs;
        };
    };
}
