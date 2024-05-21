## https://github.com/tangtang95/nixos-wsl
## Start WSL from cmd or powershell with: wsl -d NixOS
## nix flake check ./flake.nix
## sudo nixos-rebuild switch --flake .#nixos

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  wsl = {
    enable = true;
    defaultUser = "nixos";
    wslConf.interop.appendWindowsPath = false;
  };

  #nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes" ];
    # This seems to cause issues:
    # https://github.com/NixOS/nix/issues/7273
    #auto-optimise-store = true;
    #substituters = [
    #  "https://helix.cachix.org"
    #];
    #trusted-public-keys = [
    #  "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    #];
  };

  environment = {
    shells = [ pkgs.zsh ];
    variables = {
      EDITOR = "nano";
      SYSTEMD_EDITOR = "nano";
      VISUAL = "nano";
    };
  };


  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  
    # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
    #
    # Since its authority is so large, we must strengthen its security:
    # 1. The corresponding private key must be:
    #    1. Generated locally on every trusted client via:
    #      ```bash
    #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
    #      # Passphrase: digits + letters + symbols, 12+ chars
    #      ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx`
    #      ```
    #    2. Never leave the device and never sent over the network.
    # 2. Or just use hardware security keys like Yubikey/CanoKey.
    ## ssh-keygen -t ed25519 -a 256 -C "sparkx@twr-z790" -f ~/.ssh/twr-z790
    openssh.authorizedKeys.keys = [
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ13eQloVGYlOogC/eYDUcSt7p6gV3YT9LsPrNS1RDex sparkx@twr-z790"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9zeBHu14pO6uw1q5tGlSBfP+BIp+kAE2ALuqMvMSL0 root@twr-z790"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpUTXh2GRc399dcggY+QwRZvVa/lqOCO0XTVldDKi2z nixos@imc-lap-wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWMGPMbcg6eRyVJSFGb/mnVaK4gJFMXW+DQKCrI5dVG root@imc-lap-wsl"
    ];
  };

  home-manager.users.nixos = {
    imports = [
      ./home.nix
    ];
    home.stateVersion = "23.11";
  };

  nix.settings.trusted-users = ["nixos"];



  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkDefault false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      # root user is used for remote deployment, so we need to allow it
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  

  # Add terminfo database of all known terminals to the system profile.
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
