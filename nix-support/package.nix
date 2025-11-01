{ pkgs, version, ... }:

pkgs.haskellPackages.mkDerivation {
    inherit version;
    pname = builtins.baseNameOf ../.;
    src = ../.;
    isLibrary = true;
    libraryHaskellDepends = with pkgs.haskellPackages; [
        base
        ihp-hsx
        aeson
        aeson-qq
        blaze-html
        blaze-builder
        http-conduit
        http-types
        wai
        warp
        bytestring
        directory
        text
        process
        raw-strings-qq
    ];
    passthru.ghcPackages = hs: with hs; [
        base
        ihp-hsx
        aeson
        aeson-qq
        blaze-html
        blaze-builder
        http-conduit
        http-types
        wai
        warp
        bytestring
        text
        directory
        process
        raw-strings-qq
    ];
    doHaddock = false;
    license = "unknown";
}
