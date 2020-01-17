#!/usr/bin/env bash


if [ $UID -ne 0 ]; then
	echo -e "\e[40;95m--- run with a root privilege\e[0m"
	exit
fi

rm -rf /opt/pt
rm -f /usr/share/icons/gnome/48x48/mimetypes/pk{a,t,z}.png
rm -f /usr/share/mime/packages/cisco-pk{a,t,z}/xml
rm -f /usr/share/applications/cisco-{pt,ptsa}7.desktop

update-desktop-database /usr/share/applications

unlink /usr/local/bin/packettracer
hash -d packettracer

echo -e "\e[40;93m--- finished uninstalling.\e[0m"
