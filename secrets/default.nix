# import & decrypt secrets in `mysecrets` in this module
{ config, pkgs, agenix, mysecrets, ... }:

{
  imports = [
     agenix.nixosModules.default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # using the host key for decryption
    # the host key is generated on every host locally by openssh, and will never leave the host.
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets."test" = {
    # whether secrets are symlinked to age.secrets.<name>.path
    symlink = true;
    # target path for decrypted file - must already exist on os 
    path = "/etc/test/";
    # encrypted file path
    file =  "${mysecrets}/test.age";  # refers to path of test.age inside `mysecrets` repo
    mode = "0400";
    owner = "root";
    group = "root";
  };
}