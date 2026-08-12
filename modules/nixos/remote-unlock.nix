{
  config,
  vars,
  ...
}: {
  boot = {
    kernelParams = ["ip=dhcp"];
    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys =
            map
            (key: ''command="systemctl default" ${key}'')
            config.users.users.${vars.userName}.openssh.authorizedKeys.keys;
          hostKeys = ["/nix/secret/initrd/ssh_host_ed25519_key"];
        };
      };
    };
  };
}
