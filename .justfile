# List available commands
default:
    @just --list

# Rebuild and switch system to your playserver flake config
switch:
    sudo nixos-rebuild switch --flake .#playserver

# Dry-run build to verify syntax and dependencies without applying changes
check:
    nix build .#nixosConfigurations.playserver.config.system.build.toplevel --dry-run

# Update flake.lock dependencies (pins latest nixpkgs)
update:
    nix flake update