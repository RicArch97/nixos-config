<h1 align="center">NixOS Configuration</h1>

<p align="center">Desktop NixOS flake configuration using home-manager for my personal computers</p>

# Hosts

* X570AM --- X570 Aorus Master, which is the name of the motherboard, powerful multi-monitor desktop powered by AMD's Ryzen 9 5950X and Radeon RX 6900XT. Used for work, entertainment (video's / movies) and gaming.
* T470 --- Lenovo Thinkpad T470, powered by an Intel Kaby Lake CPU, used as office laptop for writing documents and programming.

![2022-10-24T16:13:17,907360430+02:00](https://user-images.githubusercontent.com/61013287/197611777-07cb9e82-2c35-4655-9244-05b41963a485.png)

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
