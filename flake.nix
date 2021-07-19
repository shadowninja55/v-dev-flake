{
  description = "v development flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    tccHeaders = {
      url = "github:shadowninja55/tcc-headers";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, tccHeaders }: let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
    devShell.x86_64-linux = let tinyccWrapper = pkgs.writeScriptBin "tccwrapper" ''
  TCC_LINKER_OPTS=$(echo "$NIX_LDFLAGS" | sed -e"s/  /;/g" | cut -d";" -f2); ${pkgs.tinycc}/bin/tcc -I${pkgs.tinycc}/lib/tcc/include -I${tccHeaders} -DCUSTOM_DEFINE_no_backtrace $NIX_CFLAGS_COMPILE $TCC_LINKER_OPTS $@
''; in pkgs.mkShell rec {
      name = "v-dev-shell";
      nativeBuildInputs = with pkgs; [
        gcc-unwrapped
        libGL
        openssl
        boehmgc
        sqlite
        libexecinfo
        xorg.libX11 
        xorg.xinput 
        xorg.libXi 
        xorg.libXext 
        xorg.libXcursor
        bintools-unwrapped
        valgrind
        tinycc
        tinyccWrapper
      ];
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeBuildInputs;
      VFLAGS = "-cc ${tinyccWrapper}/bin/tccwrapper";
    };
  };
}
