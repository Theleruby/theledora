#!/bin/bash

set -ouex pipefail

#======================================
# apply branding
#======================================
# the image-info.json is used by various scripts to do stuff and editing it borks things. for now, don't.
#rm -f /usr/share/ublue-os/image-info.json
#cat <<<"$(jq -n ".\"image-name\" |= \"theledora\" |
#              .\"image-vendor\" |= \"theleruby\" |
#              .\"image-ref\" |= \"ostree-image-signed:docker://ghcr.io/theleruby/theledora\" |
#              .\"image-tag\" |= \"${MATRIX_VARIANT}-${MATRIX_TAG}\" |
#              .\"image-branch\" |= \"${GITHUB_BRANCH}\" |
#              .\"base-image-name\" |= \"${MATRIX_FEDORA_EDITION}\" |
#              .\"fedora-version\" |= \"${MATRIX_FEDORA_VERSION}\" |
#              .\"version\" |= \"${MATRIX_FEDORA_VERSION}.${BUILD_DATE}\"" \
#    )" \
#>/usr/share/ublue-os/image-info.json

# store upstream information so we can preserve it
UPSTREAM_IMAGE_ID=$(grep -oP '^IMAGE_ID=\K.+' /etc/os-release)
SUPPORT_END=$(grep -oP '^SUPPORT_END=\K.+' /etc/os-release)
rm -f /usr/lib/os-release
cat >/usr/lib/os-release << EOL
NAME="Theledora"
VERSION="${MATRIX_FEDORA_VERSION}.${BUILD_DATE}"
RELEASE_TYPE="${MATRIX_RELEASE_TYPE}"
ID="theledora"
ID_LIKE="bazzite fedora"
VERSION_ID="${MATRIX_FEDORA_VERSION}"
VERSION_CODENAME="${MATRIX_FEDORA_EDITION}"
PRETTY_NAME="Theledora"
ANSI_COLOR="0;38;2;240;30;160"
CPE_NAME="cpe:/o:theleruby:theledora:${MATRIX_FEDORA_VERSION}"
DEFAULT_HOSTNAME="theledora"
HOME_URL="https://github.com/Theleruby/theledora"
BUG_REPORT_URL="https://github.com/Theleruby/theledora/issues"
SUPPORT_END=${SUPPORT_END}
VARIANT="${MATRIX_VARIANT}"
VARIANT_ID="${MATRIX_VARIANT}"
OSTREE_VERSION="${MATRIX_FEDORA_VERSION}.${BUILD_DATE}"
BOOTLOADER_NAME="Theledora"
BUILD_ID="${MATRIX_TAG}.${BUILD_DATE}"
IMAGE_ID="theledora-${MATRIX_VARIANT}-${MATRIX_TAG}.${BUILD_DATE}"
UPSTREAM_IMAGE_ID=${UPSTREAM_IMAGE_ID}
VENDOR_NAME="theleruby"
VENDOR_URL="https://www.theleruby.com"
EOL

if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
rm -f /etc/xdg/kcm-about-distrorc
cat >/etc/xdg/kcm-about-distrorc << EOL
[General]
Name=Theledora
LogoPath=
Website=https://github.com/Theleruby/theledora
Version=${MATRIX_FEDORA_VERSION}.${BUILD_DATE}
Variant=${MATRIX_VARIANT}-${MATRIX_TAG}
EOL
fi

rm -f /usr/lib/fedora-release
cat >/usr/lib/fedora-release << EOL
Theledora release ${MATRIX_FEDORA_VERSION}
EOL
#======================================

# print file contents for debugging
cat /usr/share/ublue-os/image-info.json
cat /usr/lib/os-release
cat /etc/xdg/kcm-about-distrorc
cat /usr/lib/fedora-release

#======================================

# make sure /var/opt directory exists so we can install stuff into it
mkdir -p /var/opt

# make sure all the fedora repo definitions are installed as bazzite doesn't include these
dnf5 install -y fedora-workstation-repositories

# make sure rpmfusion is enabled
if [ "$MATRIX_FEDORA_VERSION" == "44" ]; then
  dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${MATRIX_FEDORA_VERSION}.noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${MATRIX_FEDORA_VERSION}.noarch.rpm
fi
dnf5 config-manager setopt rpmfusion-free.enabled=1
dnf5 config-manager setopt rpmfusion-free-updates.enabled=1
dnf5 config-manager setopt rpmfusion-nonfree.enabled=1
dnf5 config-manager setopt rpmfusion-nonfree-updates.enabled=1
dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
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

# required for mounting windows dynamic disk volumes
dnf5 install -y libldm

# python
dnf5 install -y python3-devel

# chrome
dnf5 config-manager setopt google-chrome.enabled=1
dnf5 install -y google-chrome-stable

# mercurial
dnf5 install -y mercurial tortoisehg python3-dulwich kdiff3
if [ "$MATRIX_FEDORA_VERSION" == "44" ]; then
  dnf5 -y swap mercurial https://kojipkgs.fedoraproject.org//packages/mercurial/7.1.1/2.fc43/x86_64/mercurial-7.1.1-2.fc43.x86_64.rpm
fi

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

# java (jdk8 required for minecraft 1.7.10, also install latest)
dnf5 install -y https://cdn.azul.com/zulu/bin/zulu8.94.0.17-ca-fx-jdk8.0.492-linux.x86_64.rpm
dnf5 install -y java-25-openjdk-devel.x86_64
cat >/usr/share/applications/java-8-openjdk-jconsole.desktop << EOL
[Desktop Entry]
Name=OpenJDK 8 for x86_64 Monitoring & Management Console (8.0.492-zulu8.94.0.17-ca-fx.x86_64)
Comment=Monitor and manage OpenJDK applications
Exec=/usr/lib/jvm/java-8-zulu-openjdk-jdk-fx/bin/jconsole
Icon=java-25-openjdk
Terminal=false
Type=Application
StartupWMClass=sun-tools-jconsole-JConsole
Categories=Development;Profiling;Java;
Version=1.0
X-Desktop-File-Install-Version=0.28
EOL

# stuff specific to desktop variants
if [ "$MATRIX_TYPE" == "desktop" ]; then
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

# remove unwanted stuff
rm -f /usr/share/applications/discourse.desktop

if [ "$MATRIX_TYPE" == "gamescope" ]; then
  # remove HHD as I don't want or need it
  dnf5 -y remove hhd hhd-ui
fi

dnf5 clean all
