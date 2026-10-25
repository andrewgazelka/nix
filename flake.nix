{
  description = "Andrew's Mac: nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lifelog = {
      url = "github:andrewgazelka/lifelog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notify = {
      url = "github:andrewgazelka/notify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      darwinConfigurations.hydra = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
      };

      checks.aarch64-darwin.no-secrets =
        pkgs.runCommand "no-secrets" { nativeBuildInputs = [ pkgs.gitleaks ]; }
          ''
            gitleaks detect --no-banner --no-git --source ${self}
            touch $out
          '';

      formatter.aarch64-darwin = pkgs.nixfmt-tree;
    };
}
