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

  };

  outputs = { self, lean, flake-utils, nixpkgs, lake }: flake-utils.lib.eachDefaultSystem (system:
    let
      leanPkgs = lean.packages.${system};
      lakeApps = lake.apps.${system};
      lakeExe = lake.packages.${system}.lakeProject.executable;
      pkgs = import nixpkgs { inherit system; };
      name = "LeanPlay";
      pkg = leanPkgs.buildLeanPackage {
        inherit name; # must match the name of the top-level .lean file
        src = ./src;
      };
    in
    {
      packages = pkg // {
        inherit (leanPkgs) lean;
      };

      apps = lakeApps // {
        ${name} = flake-utils.lib.mkApp pkg.executable;
      };

      defaultPackage = pkg.modRoot;
      devShell = pkgs.mkShell {
        buildInputs = with leanPkgs; [ lean lakeExe ];
      };
    });
}
