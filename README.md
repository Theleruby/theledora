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

## Features

Because Theledora uses Bazzite as its upstream image, it has most of Bazzite's features. However, it also comes with its own set of extra packages. The list below tries to collect all the main features from both Bazzite and Theledora into a fairly thorough list. While not exhaustive, it should give you an idea of what to expect.

Kernel and drivers:
* Atomic semi-immutable OS based on Fedora Kinoite which uses bootc and rpm-ostree for deployment, making it extremely difficult to brick your system
* Open Gaming Collective kernel, with various gaming-related performance improvements and support for almost all relatively modern hardware
* HDR and VRR display support
* HDMI CEC support
* Latest NVIDIA display driver (NVIDIA image only)
* Xbox controller driver

Useful stuff:
* Daily automatic updates which are neither invasive nor annoying - you shouldn't even notice they're happening (desktop image only)
* Bazaar app store used to install flatpaks from Flathub
* Distrobox
* Homebrew managed by Bold Brew
* ujust command line tool to automate various actions, such as fixing common issues or installing various useful programs

Gaming:
* Steam and Lutris preinstalled
* Input Remapper which allows you to change the behaviour of various input devices

Multimedia:
* All the main audio and video codecs, including hardware accelerated support for H264 decoding
* Audacious audio player
* Audacity audio editor
* Avidemux video cutting/filtering/re-encoding tool
* EasyEffects, required for audio not to sound like junk
* FluidSynth for playing MIDIs, required by OpenTTD
* Haruna to watch videos, with VLC as a fallback option
* Kdenlive video editor
* libdvdcss, required to play DVDs
* yt-dlp to download audio and video

Image editing:
* KColorChooser for choosing colours
* KolourPaint (open source Paint clone)
* Krita image editor

Productivity:
* Discord (both stable and PTB versions)
* Multiple web browsers (Chrome, Firefox)
* LibreOffice

KDE:
* Dolphin file manager
* Filelight disk space analysis tool (similar to TreeSize or WinDirStat)
* Gwenview image viewer
* K3B image burner
* Kamoso webcam view/capture tool
* KCalc calculator
* KDE games: KPat (solitaire/freecell), KMines (minesweeper), KMahjongg, KReversi, Kiriki (yahtzee), KBlocks (tetris)
* KDiskMark and QDiskInfo to benchmark disk drives and check their SMART status
* Krusader for managing files on remote devices (similar to WinSCP or Filezilla)
* Okular PDF viewer
* Skanpage document scanning application for flatbed scanners
* Spectacle screenshot capturing and snipping tool

Miscellaneous:
* CLI commands which Fedora should have included out of the box, but didn't for some reason (e.g. htop, execstack, puttygen)
* libldm, used for mounting Windows Dynamic Disks
* JavaFX 8, required by Minecraft 1.7.10
* Java 25, for running newer Java programs
* Mercurial and TortoiseHg (including dulwich for hg-git)
* .NET runtime 8.x and 10.
* Optional GTK and QT dependency packages, without which some programs were not working as expected
* python3-devel (without this, many pip packages fail to install)
* Various fonts normally found on Windows but not Linux
* Waydroid for running Android applications
* ZeroTier

Developer packages (desktop version only):
* Docker
* .NET SDK
* Node.js
* ImageMagick headers
* MariaDB C++ connector

Optional stuff that can be quickly installed or enabled using ujust:
* ASUS ROG control center
* Boxtron, a Steam Play compatibility tool used for playing DOS games
* Cockpit server management tool
* DaVinci Resolve
* Decky Loader
* DisplayLink, needed for some laptop docks
* EmuDeck
* Framework laptop fan control
* Jetbrains Toolbox
* OpenRazer
* OpenRGB
* OpenTabletDriver
* ProtonPlus, used to manage installed Proton versions
* SteamCMD
* Sunshine game streaming host
* Tailscale

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
