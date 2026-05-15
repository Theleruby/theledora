#!/bin/bash

set -ouex pipefail

# make sure /var/opt directory exists so we can install stuff into it
mkdir -p /var/opt

# make sure all the fedora repo definitions are installed as bazzite doesn't include these
dnf5 install -y fedora-workstation-repositories

# make sure rpmfusion is enabled
dnf5 config-manager setopt rpmfusion-free.enabled=1
dnf5 config-manager setopt rpmfusion-free-updates.enabled=1
dnf5 config-manager setopt rpmfusion-nonfree.enabled=1
dnf5 config-manager setopt rpmfusion-nonfree-updates.enabled=1
dnf5 install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted

# htop
dnf5 install -y htop

# dependencies for some stuff
dnf5 install -y kdsingleapplication-qt6

# fedora stuff
dnf5 install -y mediawriter

# kde applications
dnf5 install -y filelight gwenview kcalc okular
dnf5 install -y kolourpaint krita kdenlive kamoso skanpage haruna kcolorchooser kcharselect k3b
dnf5 install -y kpat kmahjongg kiriki kreversi kblocks kmines
rm -f /usr/share/applications/gcdmaster.desktop

# easyeffects
dnf5 install -y easyeffects calf lv2 lv2-calf-plugins lv2-mdala-plugins lv2-zam-plugins lsp-plugins-lv2

# alsa plugin for dolby digital
dnf5 install -y alsa-plugins-a52

# libdvdcss for dvd playback
dnf5 install -y libdvdcss

# python
dnf5 install -y python3-devel

# chrome
dnf5 config-manager setopt google-chrome.enabled=1
dnf5 install -y google-chrome-stable

# mercurial
dnf5 install -y mercurial tortoisehg python3-dulwich kdiff3

# fluidsynth
dnf5 install -y fluidsynth fluid-soundfont-common fluid-soundfont-gm

# vlc
dnf5 install -y vlc vlc-plugins-all vlc-plugin-kde vlc-plugin-notify vlc-plugin-pipewire vlc-plugins-freeworld

# yt-dlp
dnf5 install -y yt-dlp

# zerotier
dnf5 install -y zerotier-one

# libreoffice
dnf5 install -y libreoffice libreoffice-kf6 libreoffice-help-en

# discord
dnf5 install -y discord

# audacity
dnf5 install -y audacity-freeworld

# avidemux
dnf5 install -y avidemux

# krusader
dnf5 install -y krusader

# disk utils similar to crystaldisk
dnf5 install -y kdiskmark
dnf5 copr -y enable birkch/QDiskInfo
dnf5 install -y QDiskInfo

# fonts
dnf5 install -y cabextract fontconfig
dnf5 install -y gnu-free-fonts-common gnu-free-sans-fonts lpf-cleartype-fonts lpf-mscore-fonts lpf-mscore-tahoma-fonts
rm /usr/share/applications/lpf*.desktop

# stuff specific to desktop variants
if [ "$MATRIX_TYPE" == "desktop" ]; then
  # java
  dnf5 install -y java-21-openjdk-devel.x86_64 java-25-openjdk-devel.x86_64

  # docker
  dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
  dnf5 install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

  # .net
  dnf5 install -y dotnet-sdk-8.0 dotnet-runtime-8.0
  dnf5 install -y dotnet-sdk-10.0 dotnet-runtime-10.0

  # node.js
  dnf5 install -y nodejs nodejs-npm

  # mysql
  dnf5 install -y mariadb-devel mariadb-connector-c-doc

  # imagemagick
  dnf5 install -y ImageMagick-devel
fi

# move stuff in /var/opt to /usr/lib/opt and add symlink to tmpfiles conf
# taken from https://github.com/astrovm/amyos/blob/main/build_files/fix-opt.sh, thanks <3
for dir in /var/opt/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")
  mv "$dir" "/usr/lib/opt/$dirname"
  echo "L+ /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >>/usr/lib/tmpfiles.d/move-opt-files.conf
done

if [ "$MATRIX_TYPE" == "desktop" ]; then
  # enable docker
  systemctl enable docker.service containerd.service
fi

if [ "$MATRIX_TYPE" == "gamescope" ]; then
  # remove HHD as I don't want or need it
  dnf5 -y remove hhd hhd-ui
fi

dnf5 clean all
