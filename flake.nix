# dbdb for Nix and NixOS. This flake builds nothing: it takes the programs
# of one release from https://github.com/koziserek/dbdb/releases, checks
# them against the checksums below, and fits them to Nix.
#
#   nix run github:koziserek/dbdb                    start the app
#   nix run github:koziserek/dbdb#cli -- --help      the command line
#   nix profile install github:koziserek/dbdb        keep both installed
#
# Add /v<version> for one particular release:
#   nix run github:koziserek/dbdb/v0.29.0
#
# In a NixOS or home-manager configuration, take `packages.<system>.default`
# of this flake, or add `overlays.default` and use `pkgs.dbdb`. dbdb is not
# free software, so with the overlay your own nixpkgs has to allow it
# (allowUnfreePredicate); the packages of this flake are allowed already.
#
# This file is written anew for each release; changes made here are lost.
{
  description = "dbdb: an ETL and data migration tool, as released";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "0.29.0";
      # The archive of each system, and its SHA-256 as in SHA256SUMS.
      archives = {
        x86_64-linux = { name = "linux-x86_64"; sha256 = "280dbc54df42d61d829559671c75718a266fe4076fd32db3b7d745c447a8da4c"; };
        aarch64-darwin = { name = "macos-arm64"; sha256 = "9e063447322d29bc3a80b298f954efb773b5acc5efd13ebc2f64148012d1f4c8"; };
      };
      systems = builtins.attrNames archives;

      dbdb = pkgs:
        let
          lib = pkgs.lib;
          archive = archives.${pkgs.stdenv.hostPlatform.system} or (throw
            "dbdb has no release for ${pkgs.stdenv.hostPlatform.system}");
          linux = pkgs.stdenv.hostPlatform.isLinux;
          # The window, OpenGL and Vulkan libraries are opened by name when
          # the app starts, so they have to be on its library path.
          runtimeLibs = [
            pkgs.libGL
            pkgs.libxkbcommon
            pkgs.wayland
            pkgs.vulkan-loader
          ] ++ (if pkgs ? libx11
          then [ pkgs.libx11 pkgs.libxcursor pkgs.libxi pkgs.libxrandr ]
          else [ pkgs.xorg.libX11 pkgs.xorg.libXcursor pkgs.xorg.libXi pkgs.xorg.libXrandr ]);
        in
        pkgs.stdenv.mkDerivation {
          pname = "dbdb";
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/koziserek/dbdb/releases/download/v${version}/dbdb-${version}-${archive.name}.tar.xz";
            inherit (archive) sha256;
          };

          # The programs are released for the usual loader in /lib64, which
          # NixOS does not have: autoPatchelfHook points them at the one in
          # /nix/store. Nothing else in them is changed.
          nativeBuildInputs = lib.optionals linux [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
          dontConfigure = true;
          dontBuild = true;
          dontStrip = true;
          # A Mac refuses a program that was changed after it was signed.
          dontFixup = !linux;

          installPhase =
            if linux then ''
              runHook preInstall
              install -Dm755 -t $out/bin dbdb-app dbdb-cli
              install -Dm644 -t $out/share/applications dbdb.desktop
              install -Dm644 dbdb.png $out/share/icons/hicolor/256x256/apps/dbdb.png
              install -Dm644 -t $out/share/doc/dbdb README.md LICENSE
              runHook postInstall
            '' else ''
              runHook preInstall
              mkdir -p $out/Applications $out/bin $out/share/doc/dbdb
              cp -R dbdb.app $out/Applications/
              cp dbdb-cli $out/bin/
              ln -s $out/Applications/dbdb.app/Contents/MacOS/dbdb-app $out/bin/dbdb-app
              cp README.md LICENSE $out/share/doc/dbdb/
              runHook postInstall
            '';
          postFixup = lib.optionalString linux ''
            wrapProgram $out/bin/dbdb-app \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
          '';

          meta = {
            description = "ETL and data migration tool with a desktop designer";
            homepage = "https://github.com/koziserek/dbdb";
            downloadPage = "https://github.com/koziserek/dbdb/releases";
            # Shareware: free for individuals and small organisations, paid
            # for larger ones. $out/share/doc/dbdb/LICENSE has the terms.
            license = {
              shortName = "dbdb";
              fullName = "dbdb Licence 1.0";
              url = "https://github.com/koziserek/dbdb/blob/main/LICENSE";
              free = false;
              # Unchanged copies may be passed on; what Nix makes of them
              # is not one, so no cache should hand it out.
              redistributable = false;
            };
            sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            platforms = systems;
            mainProgram = "dbdb-app";
          };
        };

      forAll = f: nixpkgs.lib.genAttrs systems (system: f (dbdb (import nixpkgs {
        inherit system;
        # Whoever names this flake has asked for dbdb, and only dbdb is
        # allowed here.
        config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "dbdb";
      })));
    in
    {
      packages = forAll (drv: { default = drv; dbdb = drv; });
      apps = forAll (drv: {
        default = { type = "app"; program = "${drv}/bin/dbdb-app"; meta.description = "The dbdb desktop app"; };
        cli = { type = "app"; program = "${drv}/bin/dbdb-cli"; meta.description = "The dbdb command line"; };
      });
      overlays.default = final: prev: { dbdb = dbdb final; };
    };
}
