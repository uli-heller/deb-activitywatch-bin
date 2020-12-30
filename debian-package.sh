#!/bin/bash
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
DD="$(dirname "${D}")"

. /etc/lsb-release

set -e

# Following this: http://www.sj-vs.net/creating-a-simple-debian-deb-package-based-on-a-directory-structure/

VERSION_NUM="0.10.0"
VERSION_DETAIL="0dp03~${DISTRIB_CODENAME}1"
VERSION="v$VERSION_NUM"
#URL="https://github.com/ActivityWatch/activitywatch/releases/download/${VERSION}/activitywatch-${VERSION}-linux-x86_64.zip"
URL="${DD}/activitywatch-${VERSION}-linux-x86_64.zip"
PKGDIR="activitywatch_$VERSION_NUM-${VERSION_DETAIL}"
ARCHIVE="${PKGDIR}_$(dpkg --print-architecture).deb"

#install tools needed for packaging
sudo apt-get install sed jdupes wget

# Prerun cleanup
if [ -d "$PKGDIR" ]; then
    sudo chown -R $USER $PKGDIR
    rm -rf $PKGDIR
fi

# Create directories
mkdir -p $PKGDIR/DEBIAN
mkdir -p $PKGDIR/opt
mkdir -p $PKGDIR/etc/xdg/autostart

# Move template files into DEBIAN
cp activitywatch_template/DEBIAN/* $PKGDIR/DEBIAN
sudo sed -i "s/Version: .*/Version: ${VERSION_NUM}-${VERSION_DETAIL}/g" $PKGDIR/DEBIAN/control

# Get and unzip binary
#wget --continue -O activitywatch-$VERSION-linux.zip $URL
unzip -q $URL -d $PKGDIR/opt/

# Hard link duplicated libraries
jdupes -L -r -S -Xsize-:1K $PKGDIR/opt/

# Set file permissions
sudo chown -R root:root $PKGDIR

#setup autostart file
sudo sed -i 's!Exec=aw-qt!Exec=/opt/activitywatch/aw-qt!' $PKGDIR/opt/activitywatch/aw-qt.desktop
(
    echo "X-GNOME-Autostart-Delay=5"
    echo "X-GNOME-UsesNotifications=true"
)|sudo tee -a $PKGDIR/opt/activitywatch/aw-qt.desktop >/dev/null
sudo cp $PKGDIR/opt/activitywatch/aw-qt.desktop $PKGDIR/etc/xdg/autostart

dpkg-deb --build $PKGDIR "${DD}/${ARCHIVE}"
