{
  description = "LeanPlay";

  inputs = {
    lean = {
      url = github:leanprover/lean4;
    };

    nixpkgs.url = github:nixos/nixpkgs/nixos-21.05;
    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lake = {
      url = github:yatima-inc/lake/acs/add-nix-flake-build;
      inputs.lean.follows = "lean";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blake3.url = github:yatima-inc/BLAKE3/acs/add-flake-setup;

  };

  outputs = { self, lean, flake-utils, nixpkgs, lake, blake3 }: flake-utils.lib.eachDefaultSystem (system:
    let
      leanPkgs = lean.packages.${system};
      lakeApps = lake.apps.${system};
      lakePkgs = lake.packages.${system};
      blake3-c = blake3.packages.${system}.BLAKE3-c;
      lakeExe = lakePkgs.lakeProject.executable;
      pkgs = import nixpkgs { inherit system; };
      name = "LeanPlay";
      cLib = import ./c/default.nix { inherit pkgs; };
      blake3Mod = leanPkgs.buildLeanPackage {
        name = "Blake3"; # must match the name of the top-level .lean file
        src = ./src;
        deps = [ leanPkgs ];
        debug = true;
        linkFlags = [ "-v -L${blake3-c}" ];
        staticLibDeps = [ cLib blake3-c ];
      };
      pkg = leanPkgs.buildLeanPackage {
        inherit name; # must match the name of the top-level .lean file
        src = ./src;
        deps = [ lakePkgs.lakeProject blake3Mod ];
        debug = true;
        linkFlags = [ "-v -L${blake3-c}" ];
        staticLibDeps = [ cLib blake3-c ];
      };
    in
    {
      packages = pkg // {
        inherit (leanPkgs) lean;
        inherit cLib;
      };

      apps = lakeApps // {
        ${name} = flake-utils.lib.mkApp {
          drv = pkg.executable;
        };
      };

      defaultApp = self.apps.${system}.${name};

      defaultPackage = pkg.modRoot;
      devShell = pkgs.mkShell {
        buildInputs = with leanPkgs; [ leanPkgs.lean lakeExe ];
        LEAN_PATH = "${leanPkgs.Lean.modRoot}:${lakePkgs.lakeProject.modRoot}";
        CPATH = "${leanPkgs.Lean.modRoot}";
      };
    });
}
