![Logo](https://raw.githubusercontent.com/Theleruby/theledora/refs/heads/main/build_files/branding/theledora.svg)

## What is Theledora?

Theledora is a customized version of Fedora Atomic Desktop based on Bazzite, a fork of Fedora Kinoite tailored towards gamers. It comes in the form of bootc images, with several variants available for different use cases.

The purpose of Theledora is to allow me to preinstall things from the Fedora package repositories which cannot be installed via flatpak, or which I found work better from the package repository. This avoids having to layer the packages using rpm-ostree, which is prone to breaking with package conflicts. Installing some of those packages also avoids me having to use containers for most of the stuff that I do (not everything, but that's OK).

## Legal notice and disclaimer

These are experimental images which were created for my sole personal use only. I don't intend for anyone to use them except me, and I don't provide any support.

I also don't consider Theledora to be its own operating system or distro - apart from the extra preinstalled packages, these bootc images are literally just of Bazzite. The customization of these images is similar to using NTLite to modify a Windows install.wim file, and was done solely to make my Atomic Desktop journey easier, being made necessary because of the particular way in which the Fedora Atomic Desktop works. All queries and legal notices which are not directly related to the customizations made to these images should therefore be directed towards Universal Blue, the Fedora Project and/or Red Hat (whichever is appropriate).

## Available images

| Variant | Purpose | Compatible GPU | Desktop environment | Gamescope session |
|--|--|--|--|--|
| desktop-nvidia-open | Desktop PC | NVIDIA GPU<br/>(1600 series or later) | KDE Plasma | No |
| gamescope | Handheld or HTPC | AMD GPU<br/>(RX 400 series or later) | KDE Plasma | Yes |

ISO installers are not currently available. To install a variant, you will therefore first need to install the upstream version of Bazzite using the provided link. After installing, enter the provided switch command and then reboot. This will switch you over to Theledora.

### Desktop variants

These variants boot directly into a KDE Plasma desktop session. The gamescope session (Steam Gaming Mode) is not included.

#### desktop-nvidia-open

This variant is based on [bazzite-nvidia-open](https://github.com/ublue-os/bazzite/pkgs/container/bazzite-nvidia-open). It comes with the NVIDIA Open GPU kernel modules, and is intended for desktop computers which have NVIDIA GeForce 1600 series or later GPUs. I tested it with my 4070 Ti SUPER and the drivers are mostly stable, with only some very minor issues. The performance in most games seems to be roughly comparable with Windows 11.

To install the upstream version:
https://download.bazzite.gg/bazzite-nvidia-open-stable-live-amd64.iso

To switch to this variant afterwards:
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:desktop-nvidia-open-stable`

### Handheld/HTPC variants

These variants are intended to be used for a handheld games console or home theater PC. They behave roughly like the Steam Deck, booting into a gamescope session (Steam Gaming Mode) by default, with a KDE Plasma desktop session being available for system maintenance tasks. If you own a Steam Deck then the experience should be very close to what you're used to already.

The gamescope session is best paired with the new Steam Controller, although it works fine with various other types of controllers. When using a non-Steam controller, the options menu can be accessed by pressing Xbox+A or equivalent.

Note that when you're using the gamescope session it will claim you're running SteamOS despite this being inaccurate. This is due to limitations of the Steam Gaming Mode UI and can just be ignored.

#### gamescope

This variant is based on [bazzite-deck](https://github.com/ublue-os/bazzite/pkgs/container/bazzite-deck). It supports AMD GPUs (RX 400 series or later) only. Intel and NVIDIA GPUs are not currently supported on this image.

To install the upstream version:
https://download.bazzite.gg/bazzite-deck-stable-live-amd64.iso

To switch to this variant afterwards:
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:gamescope-stable`

## Automatic and manual updates

All images are scheduled to rebuild every day at 10AM UTC via GitHub Actions.

Once a new image is available, the desktop version should automatically download and deploy it in the background. The gamescope version will offer the new image via the SteamOS update helper. You can also update to the latest version manually using either `rpm-ostree upgrade` (which updates only the bootc image) or `ujust update` (which runs [topgrade](https://github.com/topgrade-rs/topgrade) to update everything on the system). Running topgrade is generally a better option, as there are other dependencies that need to be kept in sync with the bootc image (e.g. NVIDIA Flatpak runtimes).

After a new image is deployed, the system will boot into it automatically next time it starts up.

### Reverting updates and pinning deployments

In the event of a problem occurring with a newly deployed image, the previous one is kept available as a backup and can be selected from the boot manager menu on startup. This helps to avoid a situation where your system ends up in a broken state due to a bad update.

By default, only two deployments are kept (the latest one and the previous one). You can pin a deployment in order to keep it forever by using `sudo ostree admin pin <X>` (where `<X>` is the deployment number, with 0 being the most recent).

A list of all deployed images (including pending updates and pinned deployments) can be displayed using `rpm-ostree status`.

## Documentation

Bazzite Documentation: https://docs.bazzite.gg/

Fedora Atomic Desktops User Guide: https://docs.fedoraproject.org/en-US/atomic-desktops/

I also made a wiki to document various Linux stuff which might be useful: https://pengwings.theleruby.com/

## Making your own image

Take a look at https://github.com/ublue-os/image-template for instructions.
