#!/bin/sh

# Copyright (c) 2017-2018 Robert LaRocca

# Use of this source code is governed by an MIT-style license that can be
# found in the projects LICENSE file or https://www.laroccx.io/LICENSE.md

SCRIPTVERSION="0.1-devel"
OPENWRTSERVER="https://downloads.openwrt.org"

list_packages(){
if [ wget -q --spider "$OPENWRTSERVER" ]; then
	opkg list-upgradable
else
	printf "$0: Error couldn't resolve: $OPENWRTSERVER\n"
fi
echo
};

total_packages(){
# 213 packages are installed
# 15 packages can be upgraded
#
local packages_installed="$(opkg list-installed 2> /dev/null | wc -l)"
local packages_upgradable="$(opkg list-upgradable 2> /dev/null | wc -l)"
printf "$packages_installed packages are installed\n"
printf "$packages_upgradable packages can be upgraded\n"
echo
};


update_packages(){
if [ "wget -q --spider $OPENWRTSERVER" ]; then
	opkg update
else
	printf "$0: Error couldn't resolve: $OPENWRTSERVER\n"
fi
echo
};

upgrade_packages(){
local packages_upgradable="$(opkg list-upgradable | awk '{ printf "%s ",$1 }')"
if [[ ! -z "$packages_upgradable" ]]; then
	opkg install $packages_upgradable
else
	printf "$0: All packages are up to date.\n"
fi
echo
};

free_memory(){
local memfree_limit=64000 # bytes
if [ "$(grep MemFree /proc/meminfo | awk '{print$2}')" -lt $memfree_limit ]; then
	for downloaded_package_lists in /var/opkg-lists/*
	do
		if [ -f "$downloaded_package_lists" ]; then
			rm -r /var/opkg-lists/*
			sync
		fi
	done
fi
echo
};

case $1 in
-V)
	printf "$0, version $SCRIPTVERSION-$(uname)\n"
	printf "Copyright (c) 2017-2018 Robert LaRocca\n"
	;;
list)
	list_packages
	total_packages
	;;
update)
	update_packages
	;;
upgrade)
	upgrade_packages
	free_memory
	;;
esac


