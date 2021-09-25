{
  description = "LeanPlay";

  inputs = {
    lean = {
      url = github:leanprover/lean4;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = github:nixos/nixpkgs/nixos-21.05;
    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lake = {
      url = github:yatima-inc/lake/acs/add-nix-flake-build;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, lean, flake-utils, nixpkgs, lake }: flake-utils.lib.eachDefaultSystem (system:
    let
      leanPkgs = lean.packages.${system};
      lakeApps = lake.apps.${system};
      lakeExe = lake.packages.${system}.lakeProject.executable;
      pkgs = import nixpkgs { inherit system; };
      pkg = leanPkgs.buildLeanPackage {
        name = "LeanPlay"; # must match the name of the top-level .lean file
        src = ./src;
      };
    in
    {
      packages = pkg // {
        inherit (leanPkgs) lean;
      };

      apps = lakeApps;

      defaultPackage = pkg.modRoot;
      devShell = pkgs.mkShell {
        buildInputs = with leanPkgs; [ lean lakeExe ];
      };
    });
}
