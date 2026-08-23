default:
    just --list

update:
    nix flake update

lint:
    statix check .

fmt:
    nix fmt .

clean:
    sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
    sudo nix-store --verify --check-contents --repair

switch:
    sudo nixos-rebuild switch --flake .#playserver

check:
    nix build .#nixosConfigurations.playserver.config.system.build.toplevel --dry-run

sops-edit:
    sops secrets/secrets.yaml

sops-rotate:
    for file in secrets/*; do \
      sops --rotate --in-place "$file"; \
    done

sops-update:
    for file in secrets/*; do \
      sops updatekeys "$file"; \
    done
