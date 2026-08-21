![Logo](https://raw.githubusercontent.com/Theleruby/theledora/refs/heads/main/build_files/theledora/theledora.svg)

## What is Theledora?

Theledora is a customized version of Fedora Atomic Desktop based on Bazzite. I created it so that I could customize the installed packages.

Project objectives:
* To have a more standardized Linux experience across the various different devices I own, with a standard set of software installed on every machine I use
* To reduce the need to use flatpaks, distrobox containers and AppImages to install things, which are more inconvenient than using dnf, and introduce extra differences between systems that I would prefer to avoid
* To avoid package conflicts that occur when using rpm-ostree to layer packages

## Legal notice and disclaimer

These are experimental images which were created for my sole personal use only. I don't intend for anyone to use them except me, and I don't provide any support. I'm still relatively new to the world of Linux and this is more of an educational project than anything serious.

I also don't consider Theledora to be its own operating system or distro - apart from the extra preinstalled packages, these bootc images are literally just of Bazzite. The customization of these images is similar to using NTLite to modify a Windows install.wim file, and was done solely to make my Atomic Desktop journey easier, being made necessary because of the particular way in which the Fedora Atomic Desktop works.

All queries and legal notices which are not directly related to the customizations made to these images should therefore be directed towards Universal Blue, the Fedora Project and/or Red Hat (whichever is appropriate).

## Available images

| Variant | Upstream image | Purpose | Compatible GPU | Desktop environment | Gamescope session | Testing branch |
|--|--|--|--|--|--|--|
| desktop | bazzite | Desktop PC | AMD or Intel GPU | KDE Plasma  (kinoite) | No | No |
| desktop-nvidia-open | bazzite-nvidia-open | Desktop PC | NVIDIA GPU<br/>(1600 series or later) | KDE Plasma  (kinoite) | No | Yes |
| desktop-nvidia-legacy | bazzite-nvidia | Desktop PC | NVIDIA GPU<br/>(GTX 900 or 1000 series) | KDE Plasma  (kinoite) | No | No |
| gamescope | bazzite-deck | Handheld or HTPC | AMD GPU<br/>(RX 400 series or later) | KDE Plasma  (kinoite) | Yes | Yes |

## Using the images

ISO installers are not currently available. To install a variant, you will therefore first need to install the upstream version of Bazzite using the provided link. After installing, enter the provided switch command and then reboot. This will switch you over to Theledora.

### desktop
For systems without NVIDIA GPU.

Install:
https://download.bazzite.gg/bazzite-stable-live-amd64.iso

Then use: 
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:desktop-stable`

### desktop-nvidia-open
Includes latest NVIDIA driver compatible with GTX 1600 series and RTX 2000/3000/4000/5000 series GPUs.

Install: 
https://download.bazzite.gg/bazzite-nvidia-open-stable-live-amd64.iso

Then use: 
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:desktop-nvidia-open-stable`

### desktop-nvidia-legacy
Includes legacy NVIDIA LTS driver for older NVIDIA GPUs, compatible with GTX 900 and 1000 series graphics cards.

Install:
https://download.bazzite.gg/bazzite-nvidia-stable-live-amd64.iso

Then use:
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:desktop-nvidia-legacy-stable`

### gamescope
Includes SteamOS gaming mode. Intended for use with handheld and HTPC devices. Compatible with AMD RX 400 series GPU or later only.

Install:
https://download.bazzite.gg/bazzite-deck-stable-live-amd64.iso

Then use:
`sudo bootc switch --enforce-container-sigpolicy ghcr.io/theleruby/theledora:gamescope-stable`

## Automatic and manual updates

All images are scheduled to rebuild every day at 10AM UTC via GitHub Actions.

Once a new image is available, the desktop version should automatically download and deploy it in the background. The gamescope version will offer the new image via the SteamOS update helper. You can also update to the latest version manually using either `rpm-ostree upgrade` (which updates only the bootc image) or `ujust update` (which updates everything on the system). Running the ujust command is generally a better option, as there are other dependencies that need to be kept in sync with the bootc image (e.g. NVIDIA Flatpak runtimes).

After a new image is deployed, the system will boot into it automatically next time it starts up.

### Reverting updates and pinning deployments

In the event of a problem occurring with a newly deployed image, the previous one is kept available as a backup and can be selected from the boot manager menu on startup. This helps to avoid a situation where your system ends up in a broken state due to a bad update.

By default, only two deployments are kept (the latest one and the previous one). You can pin a deployment in order to keep it forever by using `sudo ostree admin pin <X>` (where `<X>` is the deployment number, with 0 being the most recent).

A list of all deployed images (including pending updates and pinned deployments) can be displayed using `rpm-ostree status`.

## Changelogs

Changelogs for Theledora are published to https://tups.theledora.org/

## Documentation

Bazzite Documentation: https://docs.bazzite.gg/

Fedora Atomic Desktops User Guide: https://docs.fedoraproject.org/en-US/atomic-desktops/

I also made a wiki to document various Linux stuff which might be useful: https://pengwings.theleruby.com/

## Making your own image

Take a look at https://github.com/ublue-os/image-template for instructions.
