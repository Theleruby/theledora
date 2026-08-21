#!/bin/bash

set -euxo pipefail

#======================================
# apply branding
#======================================

# main branding files
mkdir -p /usr/share/ublue-os/theledora/
cp /ctx/theledora/* /usr/share/ublue-os/theledora/

# plymouth watermark
rm -f /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/misc/watermark.png /usr/share/plymouth/themes/spinner/watermark.png

# the image-info.json is used by various scripts to do stuff and editing it borks things. for now we use our own file
#rm -f /usr/share/ublue-os/image-info.json
cat <<<"$(jq -n ".\"image-name\" |= \"theledora\" |
              .\"image-vendor\" |= \"theleruby\" |
              .\"image-ref\" |= \"ostree-image-signed:docker://ghcr.io/theleruby/theledora\" |
              .\"image-tag\" |= \"${MATRIX_VARIANT}-${MATRIX_TAG}\" |
              .\"image-branch\" |= \"${GITHUB_BRANCH}\" |
              .\"base-image-name\" |= \"${MATRIX_FEDORA_EDITION}\" |
              .\"fedora-version\" |= \"${MATRIX_FEDORA_VERSION}\" |
              .\"version\" |= \"${MATRIX_FEDORA_VERSION}.${BUILD_DATE}.${BUILD_RUN_NUMBER}\"" \
    )" \
>/usr/share/ublue-os/theledora/image-info.json

# store upstream information so we can preserve it
UPSTREAM_IMAGE_ID=$(grep -oP '^IMAGE_ID=\K.+' /etc/os-release)
SUPPORT_END=$(grep -oP '^SUPPORT_END=\K.+' /etc/os-release)
rm -f /usr/lib/os-release
cat >/usr/lib/os-release << EOL
NAME="Theledora"
VERSION="${MATRIX_FEDORA_VERSION}.${BUILD_DATE}.${BUILD_RUN_NUMBER}"
RELEASE_TYPE="${MATRIX_RELEASE_TYPE}"
ID="theledora"
ID_LIKE="bazzite fedora"
VERSION_ID="${MATRIX_FEDORA_VERSION}"
VERSION_CODENAME="${MATRIX_FEDORA_EDITION}"
PRETTY_NAME="Theledora"
ANSI_COLOR="0;38;2;240;30;160"
CPE_NAME="cpe:/o:theleruby:theledora:${MATRIX_FEDORA_VERSION}"
DEFAULT_HOSTNAME="theledora"
HOME_URL="https://www.theledora.org"
BUG_REPORT_URL="https://github.com/Theleruby/theledora/issues"
SUPPORT_END=${SUPPORT_END}
VARIANT="${MATRIX_VARIANT}"
VARIANT_ID="${MATRIX_VARIANT}"
OSTREE_VERSION="${MATRIX_FEDORA_VERSION}.${BUILD_DATE}.${BUILD_RUN_NUMBER}"
BOOTLOADER_NAME="Theledora"
BUILD_ID="${MATRIX_TAG}.${BUILD_DATE}.${BUILD_RUN_NUMBER}"
IMAGE_ID="theledora-${MATRIX_VARIANT}-${MATRIX_TAG}.${BUILD_DATE}.${BUILD_RUN_NUMBER}"
UPSTREAM_IMAGE_ID=${UPSTREAM_IMAGE_ID}
VENDOR_NAME="theleruby"
VENDOR_URL="https://www.theleruby.com"
EOL

if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
#--
cat >/usr/bin/upstream-image-id <<EOL
#!/bin/bash
echo "Upstream Image:"
echo "${UPSTREAM_IMAGE_ID}"
echo ""
EOL
chmod +x /usr/bin/upstream-image-id
#--
rm -f /etc/xdg/kcm-about-distrorc
cat >/etc/xdg/kcm-about-distrorc << EOL
[General]
Name=Theledora
LogoPath=/usr/share/ublue-os/theledora/theledora-box.png
Website=https://www.theledora.org
Version=${MATRIX_FEDORA_VERSION}.${BUILD_DATE}.${BUILD_RUN_NUMBER}
Variant=${MATRIX_VARIANT}-${MATRIX_TAG}
ExtraSoftwareData=/usr/bin/upstream-image-id
EOL
#--
fi

# fastfetch/motd stuff
rm -f /etc/profile.d/bazzite-neofetch.sh
cp /ctx/misc/theledora-neofetch.sh /etc/profile.d/theledora-neofetch.sh
chmod +x /etc/profile.d/theledora-neofetch.sh
rm -rf /usr/share/ublue-os/motd
rm -rf /usr/libexec/ublue-motd
cp /ctx/misc/ublue-motd /usr/libexec/ublue-motd
chmod +x /usr/libexec/ublue-motd

# gamemode news hook announcements. currently borked
if [ "$MATRIX_TYPE-$MATRIX_FEDORA_VERSION" == "gamescope-44" ]; then
  sed -i "s|^github = .*|github = https://tups.theledora.org/api/announcements/theledora/${GITHUB_BRANCH}/updates.json|" /etc/gamemode-news-hook.conf
fi

# stop the branch being changed in big picture mode by replacing os-branch-select with a dummy script
# (required to prevent it showing junk branches and calling brh)
if [ "$MATRIX_TYPE" == "gamescope" ]; then
  rm -f /usr/libexec/os-branch-select
  cp /ctx/misc/os-branch-select /usr/libexec/os-branch-select
fi

# fix update version being displayed (os parse error)
if [ "$MATRIX_TYPE-$MATRIX_FEDORA_VERSION" == "gamescope-44" ]; then
  rm -f /usr/libexec/ogc/os-update
  cp /ctx/misc/os-update /usr/libexec/ogc/os-update
fi

rm -f /usr/lib/fedora-release
cat >/usr/lib/fedora-release << EOL
Theledora release ${MATRIX_FEDORA_VERSION}
EOL

# this was replaced with a UI program (bazzite-updater) that I'm removing as it hasn't been updated for Theledora yet
# put the shortcut back for now as it will still work
cat >/usr/share/applications/system-update.desktop << EOL
[Desktop Entry]
Type=Application
Name=System Update
Name[cs]=Aktualizace systému
Name[fr]=Mises à jour
Name[el]=Ενημέρωση συστήματος
Name[ru]=Обновление системы
Comment=Update Theledora, Flatpaks, and more
Comment[cs]=Aktualizace Theledora, Flatpaků a dalších
Comment[fr]=Met à jour Theledora, les applications et plus encore
Comment[el]=Ενημερώνει το Theledora, τα Flatpaks και άλλα
Comment[ru]=Обновить Theledora, Flatpak и многое другое
Icon=/usr/share/ublue-os/theledora/update.svg
Categories=ConsoleOnly;System;
Terminal=true
Exec=/usr/bin/ujust update
EOL

# display sudo password feedback by default
cat >/etc/sudoers.d/enable-pwfeedback << EOL
Defaults pwfeedback
EOL

# remove unwanted ujust commands
cat >>/usr/share/ublue-os/justfile << EOL

[private]
toggle-nvk:
    @echo "Unsupported on Theledora"

[private]
get-decky-bazzite-buddy:
    @echo "Unsupported on Theledora"

[private]
add-updater-to-steam:
    @echo "Unsupported on Theledora"

[private]
password-feedback:
    @echo "Unsupported on Theledora"

[private]
changelogs:
    @echo "Unsupported on Theledora"

[private]
changelogs-testing:
    @echo "Unsupported on Theledora"

[private]
restore-bazzite-breeze-gtk-theme:
    @echo "Unsupported on Theledora"

[private]
verify-image:
    @echo "Unsupported on Theledora"
EOL

#======================================

# print file contents for debugging
cat /usr/share/ublue-os/image-info.json
cat /usr/share/ublue-os/theledora/image-info.json
cat /usr/lib/os-release
if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
  cat /usr/bin/upstream-image-id
  cat /etc/xdg/kcm-about-distrorc
fi
if [ "$MATRIX_TYPE-$MATRIX_FEDORA_VERSION" == "gamescope-44" ]; then
  cat /etc/gamemode-news-hook.conf
fi
cat /usr/lib/fedora-release
#if [ "$MATRIX_TYPE-$MATRIX_RELEASE_TYPE" == "desktop-stable" ]; then
#  cat /usr/share/applications/system-update.desktop
#fi

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

# basic command line tools that should have just been in fedora by default
dnf5 install -y htop execstack libzip-tools putty

# dependencies for some stuff
if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
  dnf5 install -y kdsingleapplication-qt6
fi
dnf5 install -y gtk2 gtk3

# fedora stuff
dnf5 install -y mediawriter

# kde applications
if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
  dnf5 install -y filelight gwenview kcalc okular
  dnf5 install -y kolourpaint krita kdenlive kamoso skanpage haruna kcolorchooser kcharselect k3b okteta kclock kweather
  dnf5 install -y kpat kmahjongg kiriki kreversi kblocks kmines ksudoku kapman kbounce knights palapeli
  rm -f /usr/share/applications/gcdmaster.desktop
fi

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

# firefox
dnf5 install -y firefox --allowerasing

# mercurial
dnf5 install -y mercurial tortoisehg python3-dulwich kdiff3

# fluidsynth
dnf5 install -y fluidsynth fluid-soundfont-common fluid-soundfont-gm

# audacious
dnf5 install -y audacious audacious-plugins audacious-plugins-freeworld libopenmpt

# vlc
dnf5 install -y vlc vlc-plugins-all vlc-plugin-kde vlc-plugin-notify vlc-plugin-pipewire
if [ "$MATRIX_FEDORA_VERSION" == "44" ]; then
  dnf5 install -y https://stuff.theleruby.com/rpm/vlc-plugins-freeworld-3.0.22-3.fc45.x86_64.rpm
else
  dnf5 install -y vlc-plugins-freeworld
fi

# yt-dlp
dnf5 install -y yt-dlp

# zerotier
dnf5 install -y zerotier-one

# libreoffice
if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
  dnf5 install -y libreoffice libreoffice-kf6 libreoffice-help-en
else
  dnf5 install -y libreoffice libreoffice-gtk3 libreoffice-help-en
fi

# discord
dnf5 install -y https://discord.com/api/download?platform=linux\&format=rpm
dnf5 install -y https://discord.com/api/download/ptb?platform=linux\&format=rpm

# audacity
dnf5 install -y audacity-freeworld

# avidemux
if [ "$MATRIX_FEDORA_VERSION" == "44" ]; then
# broken on bazzite 44 now. use appimage
wget https://stuff.theleruby.com/AppImage/Avidemux-x86_64_20260516.AppImage -O /usr/bin/avidemux.AppImage
chmod +x /usr/bin/avidemux.AppImage
wget https://stuff.theleruby.com/AppImage/org.avidemux.Avidemux.png -O /usr/share/icons/hicolor/128x128/apps/org.avidemux.Avidemux.png
cat >/usr/share/applications/org.avidemux.Avidemux.desktop << EOL
[Desktop Entry]
Name=Avidemux
GenericName=Video Editor
Comment=Multiplatform video editor
Exec=/usr/bin/avidemux.AppImage %f
Icon=org.avidemux.Avidemux
Terminal=false
Type=Application
Categories=AudioVideo;AudioVideoEditing;Video;
MimeType=video/mpeg;video/x-mpeg;video/mp4;video/x-m4v;video/quicktime;video/3gp;video/mkv;video/x-matroska;video/webm;video/flv;video/x-flv;video/dv;video/x-msvideo;video/x-ms-wmv;video/x-ms-asf;video/x-anim;
EOL
else
  dnf5 install -y avidemux
fi

# krusader
dnf5 install -y krusader

# disk utils similar to crystaldisk
dnf5 install -y kdiskmark
dnf5 copr -y enable birkch/QDiskInfo
dnf5 install -y QDiskInfo
dnf5 copr -y disable birkch/QDiskInfo

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

# .net runtimes
dnf5 install -y dotnet-runtime-8.0 dotnet-runtime-10.0

# needed for JFXPanel swing interop, not sure which one as it wasn't clear, so just installing both
dnf5 install -y gtk2-devel gtk3-devel

# stuff specific to desktop variants
if [ "$MATRIX_TYPE" == "desktop" ]; then
  # docker
  dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
  dnf5 install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

  # .net sdk
  dnf5 install -y dotnet-sdk-8.0 dotnet-sdk-10.0

  # node.js
  dnf5 install -y nodejs nodejs-npm

  # mysql
  dnf5 install -y mariadb-devel mariadb-connector-c-doc

  # imagemagick
  dnf5 install -y ImageMagick-devel
fi

# remove HHD as I don't need it. this was removed in bazzite 44 anyway.
if [ "$MATRIX_TYPE-$MATRIX_FEDORA_VERSION" == "gamescope-43" ]; then
  dnf5 -y remove hhd hhd-ui
fi

# remove stuff that's specific to bazzite and not relevant to theledora. some of this I should probably replace with an equivalent at some point
rm -f /usr/bin/bazzite-rollback-helper
rm -f /usr/bin/brh
rm -f /usr/bin/bruh
if [ "$MATRIX_FEDORA_VERSION" == "44" ]; then
  dnf5 -y remove bazzite-updater
fi
rm -f /usr/share/applications/bazzite-documentation.desktop
rm -f /usr/share/applications/discourse.desktop
dnf5 -y remove bazzite-portal
if [ "$MATRIX_FEDORA_EDITION" == "kinoite" ]; then
  dnf5 -y remove krunner-yafti
else
  dnf5 -y remove gnome-search-yafti
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

dnf5 clean all

# rebuild initramfs
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' "kernel${KERNEL_SUFFIX:+-${KERNEL_SUFFIX}}")"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree --add fido2 -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
