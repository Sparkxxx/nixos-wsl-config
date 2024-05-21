
1. Clone this repo using ssh since we will use another private repo (the secret's one)

* Prepare ssh cli environment:
  - Create ~/.ssh/config file with at leaset the following content:
  
  ```
  Host github-sparkx
    # git clone git@github-sparkx:Sparkxxx/nix-secrets.git .
    Hostname github.com
    IdentityFile ~/.ssh/id_ed25519_github_sparkxxx
    IdentitiesOnly yes # required to prevent the SSH default behavior of sending the identity file matching the default filename for each protocol
    AddKeysToAgent yes # lets you avoid reentering the key passphrase every time
  ```

  Clone the repo with: 
    git clone git@github-sparkx:Sparkxxx/nixos-wsl-config.git

  
  