ActivityWatch
=============

Quellen
-------

* [activitywatch-v0.9.2-linux-x86-64.zip](https://github.com/ActivityWatch/activitywatch/releases)
* [deb-activitywatch-bin-master](https://github.com/ActivityWatch/deb-activitywatch-bin)

Ablauf
------

1. ZIP-Datei herunterladen: [activitywatch-v0.9.2-linux-x86-64.zip](https://github.com/ActivityWatch/activitywatch/releases/activitywatch-v0.9.2-linux-x86-64.zip)
2. DEB-Paketierungsprojekt herunterladen
3. Paketierungsprojekt auspacken
4. Skript anpassen - siehe "Änderungen"
5. `sh ./debian-package.sh`

Änderungen
----------

```diff
buntu@ubuntu-2004-build:~/build/activitywatch$ diff -u deb-activitywatch-bin-master/debian-package.sh activitywatch-0.9.2/debian-package.sh
--- deb-activitywatch-bin-master/debian-package.sh	2020-05-16 18:52:36.000000000 +0200
+++ activitywatch-0.9.2/debian-package.sh	2020-06-11 09:01:42.218889411 +0200
@@ -1,13 +1,19 @@
 #!/bin/bash
+D="$(dirname "$0")"
+D="$(cd "${D}" && pwd)"
+DD="$(dirname "${D}")"
 
 set -e
 
 # Following this: http://www.sj-vs.net/creating-a-simple-debian-deb-package-based-on-a-directory-structure/
 
 VERSION_NUM="0.9.2"
+VERSION_DETAIL="0dp01~focal1"
 VERSION="v$VERSION_NUM"
-URL="https://github.com/ActivityWatch/activitywatch/releases/download/${VERSION}/activitywatch-${VERSION}-linux-x86_64.zip"
-PKGDIR="activitywatch_$VERSION_NUM"
+#URL="https://github.com/ActivityWatch/activitywatch/releases/download/${VERSION}/activitywatch-${VERSION}-linux-x86_64.zip"
+URL="${DD}/activitywatch-${VERSION}-linux-x86_64.zip"
+PKGDIR="activitywatch_$VERSION_NUM-${VERSION_DETAIL}"
+ARCHIVE="${PKGDIR}_$(dpkg --print-architecture).deb"
 
 #install tools needed for packaging
 sudo apt-get install sed jdupes wget
@@ -25,11 +31,11 @@
 
 # Move template files into DEBIAN
 cp activitywatch_template/DEBIAN/* $PKGDIR/DEBIAN
-sudo sed -i "s/Version: .*/Version: $VERSION_NUM/g" $PKGDIR/DEBIAN/control
+sudo sed -i "s/Version: .*/Version: ${VERSION_NUM}-${VERSION_DETAIL}/g" $PKGDIR/DEBIAN/control
 
 # Get and unzip binary
-wget --continue -O activitywatch-$VERSION-linux.zip $URL
-unzip -q activitywatch-$VERSION-linux.zip -d $PKGDIR/opt/
+#wget --continue -O activitywatch-$VERSION-linux.zip $URL
+unzip -q $URL -d $PKGDIR/opt/
 
 # Hard link duplicated libraries
 jdupes -L -r -S -Xsize-:1K $PKGDIR/opt/
@@ -41,4 +47,5 @@
 sudo sed -i 's!Exec=aw-qt!Exec=/opt/activitywatch/aw-qt!' $PKGDIR/opt/activitywatch/aw-qt.desktop
 sudo cp $PKGDIR/opt/activitywatch/aw-qt.desktop $PKGDIR/etc/xdg/autostart
 
-dpkg-deb --build $PKGDIR
+dpkg-deb --build $PKGDIR "${DD}/${ARCHIVE}"
+
```