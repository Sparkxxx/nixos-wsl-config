
## Configure ssh to be able to clone private repos using ssh keys:
## in ~/.ssh/config add for both your user and ROOT user
# Host github-sparkx
#     # git clone git@github-sparkx:Sparkxxx/<REPO>.git .
#     Hostname github.com
#     IdentityFile ~/.ssh/id_ed25519_github_sparkxxx
#     IdentitiesOnly yes # is required to prevent the SSH default behavior of sending the identity file matching the default filename for each protocol
#     AddKeysToAgent yes # lets you avoid reentering the key passphrase every time
## Check IdentityFile exists in location.
## github-sparkx is used in inputs.mysecrets definition.

## https://github.com/tangtang95/nixos-wsl
## Start WSL from cmd or powershell with: wsl -d NixOS
## nix flake check ./flake.nix

## sudo nixos-rebuild switch --flake  /mnt/c/Users/IMC-1/_work_/nixos-wsl-config/#nixos
## sudo nixos-rebuild switch --flake .#nixos
## sudo nixos-rebuild switch --impure --flake .#nixos

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
    # the colon ':' directly after the domain name should be a forward slash /. So the resulting URL would be
    #    git+ssh://git@git.example.com/User/repo.git
    # github-sparkx is defined in ~/.ssh/config
    mysecrets = { 
      url = "git+ssh://git@github-sparkx/Sparkxxx/nix-secrets.git?shallow=1"; 
      flake = false; 
    };
  };

  outputs = inputs @ { self, nixpkgs, NixOS-WSL, home-manager, agenix, mysecrets, ... }: {
  #outputs = inputs @ { self, nixpkgs, NixOS-WSL, home-manager, ... }: {
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
          {
           system.stateVersion = "23.11";
           wsl.enable = true;
          }

          home-manager.nixosModules.home-manager

          # import & decrypt secrets in `mysecrets` in this module
          ./secrets/default.nix

        ];
      };
    };
  };
}
