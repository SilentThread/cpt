#!/usr/bin/env bash


if [ $UID -ne 0 ]; then
	echo -e "\e[40;95m--- run with a root privilege\e[0m"
	exit
fi

if [ ! -f "$1" ]; then
	echo -e "\e[40;96m--- can not find an install archive. (try \"[sudo] ./install.sh ARCHIVE_FILE]\")"
	exit
fi



instdir="/opt"
while read -p $'\n Enter destination dir (default=/opt) : ' instdir0
do
	if [ -z "$instdir0" ]; then
		break
	elif [ -d "$instdir0" ]; then
		instdir="$instdir0"
		break
	else
		echo -e "\e[31m--- dir does not exit.\e[0m"
	fi
done
echo -e "\e[40;36m--- using $instdir\e[0m"



echo -e "\e[40;93m--- Unpacking...\e[0m"
tar -axf $1 -P -C $instdir || exit 1
# gtk-update-icon-cache /usr/share/icons/hicolor



echo -e "\e[40;93m--- Updating config...\e[0m"
cat > /etc/profile.d/packettracer.sh <<- TRACER

	export PT7HOME=$instdir/pt
	export QT_DEVICE_PIXEL_RATIO=auto

TRACER

cat > /usr/share/applications/cisco-pt7.desktop <<- CPT
	[Desktop Entry]
	Type=Application
	Exec=$instdir/pt/packettracer %f:
	Name=Packet Tracer 7.3.0
	Icon=$instdir/pt/art/app.png
	Terminal=false
	MimeType=application/x-pkt;application/x-pka;application/x-pkz;
CPT

cat > /usr/share/applications/cisco-ptsa7.desktop <<- CPT-SA
	[Desktop Entry]
	Type=Application
	Exec=$instdir/pt/packettracer -uri=%u
	Name=Packet Tracer S.A
	Icon=$instdir/pt/art/app.png
	Terminal=false
	MimeType=x-scheme-handler/pttp;
CPT-SA

update-desktop-database /usr/share/applications
ln -sf $instdir/pt/packettracer /usr/local/bin/packettracer

# mkdir -p /usr/lib64/packettracer
# cp $(dirname $BASH_SOURCE)/lib/* /usr/lib64/packettracer/
# ln -srf /usr/lib64/packettracer/libdouble-conversion.so.1.0 /usr/lib64/packettracer/libdouble-conversion.so.1
# ln -srf /usr/lib64/packettracer/libjpeg.so.8.2.2 /usr/lib64/packettracer/libjpeg.so.8
# cat > /etc/ld.so.conf.d/cisco-pt7-x86_64.conf <<- LINKER
# 	/usr/lib64/packettracer
# LINKER
# ldconfig



echo -e "\e[40;93m--- Copying required libs...\e[0m"
__OS_VER=$(awk -F= '/^VERSION_ID/ { print $2 }' /etc/os-release | tr -d \" | cut -d. -f1)
__CWD=$(dirname $BASH_SOURCE)

cp $__CWD/lib/libjpeg.so.8.2.2 $instdir/pt/bin/
ln -srf $instdir/pt/bin/libjpeg.so.8.2.2 $instdir/pt/bin/libjpeg.so.8

cp $__CWD/lib/libdouble-conversion.so.1.0 $instdir/pt/bin/
ln -srf $instdir/pt/bin/libdouble-conversion.so.1.0 $instdir/pt/bin/libdouble-conversion.so.1


unset instdir0 instdir __OS_VER __CWD

#/opt/pt/
#/usr/local/bin/packettracer
#/usr/share/applications/cisco-pt7.desktop
#/usr/share/applications/cisco-ptsa7.desktop
#/usr/share/icons/gnome/48x48/mimetypes/pka.png
#/usr/share/icons/gnome/48x48/mimetypes/pkt.png
#/usr/share/icons/gnome/48x48/mimetypes/pkz.png
#/usr/share/mime/packages/cisco-pka.xml
#/usr/share/mime/packages/cisco-pkt.xml
#/usr/share/mime/packages/cisco-pkz.xml

