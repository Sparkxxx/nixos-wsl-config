
## https://github.com/tangtang95/nixos-wsl
## Start WSL from cmd or powershell with: wsl -d NixOS
## nix flake check ./flake.nix

## sudo nixos-rebuild switch --flake  /mnt/c/Users/IMC-1/_work_/nixos-wsl-config/#nixos
## sudo nixos-rebuild switch --flake .#nixos

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management tool
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my private secrets, it's a private repository, you need to replace it with your own.
    mysecrets = { 
      url = "github:Sparkxxx/nix-secrets"; 
      flake = false; 
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Set all input parameters as specialArgs of all sub-modules
        # so that we can use the `agenix` & `mysecrets` in sub-modules
        specialArgs = inputs;

        modules = [
          { 
            nix.registry.nixpkgs.flake = nixpkgs; 
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }

          ./configuration.nix
          
          #NixOS-WSL.nixosModules.default
          NixOS-WSL.nixosModules.wsl
          #{
          #  system.stateVersion = "23.11";
          #  wsl.enable = true;
          #}

          home-manager.nixosModules.home-manager

          # import & decrypt secrets in `mysecrets` in this module
          ./secrets/default.nix

        ];
      };
    };
  };
}
