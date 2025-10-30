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
        cryptonite
        http-conduit
        http-types
        monad-logger
        password
        persistent
        persistent-mysql
        persistent-postgresql
        persistent-sqlite
        regex-compat
        wai
        warp
        time
        bytestring
        text
        raw-strings-qq
    ];
    passthru.ghcPackages = hs: with hs; [
        base
        ihp-hsx
        aeson
        aeson-qq
        blaze-html
        blaze-builder
        cryptonite
        http-conduit
        http-types
        monad-logger
        password
        persistent
        persistent-mysql
        persistent-postgresql
        persistent-sqlite
        regex-compat
        wai
        warp
        time
        bytestring
        text
        raw-strings-qq
    ];
    doHaddock = false;
    license = "unknown";
}
