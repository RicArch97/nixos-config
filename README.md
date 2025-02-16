<h1 align="center">NixOS Configuration</h1>

<p align="center">Desktop NixOS flake configuration using home-manager for my personal computers</p>

# Hosts

* North --- fully watercooled black/gold/wood build for personal use (gaming) and occasionally work.
* X570AM --- X570 Aorus Master, which is the name of the motherboard, powerful multi-monitor desktop powered by AMD's Ryzen 9 5950X and Radeon RX 6900XT. Used for work, entertainment (video's / movies) and gaming.

![2024-01-21T19:05:14,760450837+01:00](https://github.com/RicArch97/nixos-config/assets/61013287/92cc6906-6a10-4e49-9e51-f47ea6598424)

# Contents

* [bin](bin): Collection of scripts globally available in the system.
* [config](config): User configuration for applications which is symlinked, used for complex configurations (like EWW) or assets.
* [hosts](hosts): Per host configuration / module enablement.
* [installation](installation): Partitioning / install scripts for a ZFS install. (ext4 not covered, refer to the NixOS manual)
* [modules](modules): Modules for everything that can be specifically enabled or disabled.
* [packages](packages): Custom packages for stuff not available in nixpkgs.

Modules are used for everything to make it as modular as possible, with some enabled by default. Home mananger configuration is not separate however, thus required.

# References

These configs were written without any prior Nix experience and I've taken a lot from existing configs to create mine.

I thank all these people for sharing their configurations for me to learn from!

* hlissner: https://github.com/hlissner/dotfiles (a lot was taken from here)
* KubqoA: https://github.com/KubqoA/dotfiles
* balsoft: https://github.com/balsoft/nixos-config
* fufexan: https://github.com/fufexan/dotfiles
* viperML: https://github.com/viperML/dotfiles
* spikespaz: https://github.com/spikespaz/dotfiles
