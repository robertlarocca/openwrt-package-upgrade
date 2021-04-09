#!/bin/sh

# Copyright (c) 2017-2021 Robert LaRocca

# Use of this source code is governed by an MIT-style license that can be
# found in the projects LICENSE file or https://www.laroccx.com/LICENSE.md

#-------------------- Global Variables --------------------#

# development
script_version="1.0.2"
script_release='release'	# options devel, beta, release

openwrt_server="http://downloads.openwrt.org"

#-------------------- Global Variables --------------------#

list_packages() {
	if [[ "wget -q --spider $openwrt_server" ]]; then
		opkg list-upgradable
	else
		echo "$(basename $0): Error couldn't resolve: $openwrt_server"
	fi
};

total_packages() {
	# 213 packages are installed
	local packages_installed="$(opkg list-installed 2> /dev/null | wc -l)"
	echo "$packages_installed packages are installed"

	# 15 packages can be upgraded
	local packages_upgradable="$(opkg list-upgradable 2> /dev/null | wc -l)"
	echo "$packages_upgradable packages can be upgraded"
};

update_packages() {
	if [[ "wget -q --spider $openwrt_server" ]]; then
		opkg update
	else
		echo "$(basename $0): Error couldn't resolve: $openwrt_server"
	fi
};

upgrade_packages() {
	local packages_upgradable="$(opkg list-upgradable | awk '{ printf "%s ",$1 }')"
	if [[ ! -z "$packages_upgradable" ]]; then
		opkg install $packages_upgradable
	else
		echo "$(basename $0): All packages are up-to-date."
	fi
};

free_memory() {
	local memfree_limit=64000 # bytes
	if [[ "$(grep MemFree /proc/meminfo | awk '{print$2}')" -lt $memfree_limit ]]; then
		for downloaded_package_lists in /var/opkg-lists/*
		do
			if [[ -f "$downloaded_package_lists" ]]; then
				rm -r /var/opkg-lists/*
				sync
			fi
		done
	fi
};

display_version() {
	cat <<-EOF_XYZ
	$(basename $0), version $script_version-$script_release
	Copyright (c) 2017-$(date +%Y) Robert LaRocca
	Source <https://github.com/robertlarocca/openwrt-package-upgrade>
	EOF_XYZ
};

display_help() {
	cat <<-EOF_XYZ
	Usage: $(basename $0) [option] [--help] [--version]

	Options:
	 all		Perform all upgrade tasks
	 list		List upgradable packages
	 update		Update package repositories and signatures
	 upgrade	Upgrade all available packages
	 help		Display command usage and exit
	 version	Show version and copyright information

	Examples:
	 $(basename $0) all
	 $(basename $0) list
	 $(basename $0) update
	 $(basename $0) upgrade

	Version:
	 $(basename $0), version $script_version-$script_release
	 Copyright (c) 2017-$(date +%Y) Robert LaRocca
	 Source <https://github.com/robertlarocca/openwrt-package-upgrade>
	EOF_XYZ
};

case $1 in
version | --version)
	display_version
	;;
help | --help)
	display_help
	;;
list | --list)
	list_packages
	total_packages
	;;
update | --update)
	update_packages
	;;
upgrade | --upgrade)
	upgrade_packages
	free_memory
	;;
* | all | --all)
	update_packages
	list_packages
	total_packages
	upgrade_packages
	free_memory
	;;
esac
