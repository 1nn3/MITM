#!/usr/bin/env sh
# Set up a WiFi hotspot with NetworkManager under Kali linux

#set -x
set -e

export LANG="C"
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

usage () {
	cat <<! 1>&2
Usage: $0 <start|stop|status> ;-)
!
	exit 1
}
startup () {
	nmcli radio wifi on

	# Das Interface muss den Modus AP unterstützen:
	nmcli -f WIFI-PROPERTIES device show "$if" \
		| grep "^WIFI-PROPERTIES.AP: \s*yes$" || exit

	nmcli device wifi hotspot ifname "$if" ssid "$ssid"

	nmcli device wifi show-password
}
cleanup () {
	# TODO
	nmcli radio wifi off &&	nmcli radio wifi on
}
status () {
	nmcli device wifi show-password
}

# Interface
con=${con:-`nmcli -g uuid,state connection | awk -F ':' '$2=="activated" {print $1; exit}'`}
if=`nmcli -t connection show $con | sed -n -E "/^GENERAL\.DEVICES:/s///p"`
ssid="WiFi AP"

TEMP=$(getopt -o 'hi:s:' --long 'help,interface:ssid:' -n "$0" -- "$@")

if [ $? -ne 0 ]; then
	usage
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
	case "$1" in
		'-h'|'--help')
			echo 'Option -h, --help'
			shift 1
			usage
			exit
		;;
		'-i'|'--interface')
			echo "Option -i, --interface; argument '$2'"
			if="$2"
			shift 2
			continue
		;;
		'-s'|'--ssid')
			echo "Option -s, --ssid; argument '$2'"
			ssid="$2"
			shift 2
			continue
		;;
		'--')
			shift
			break
		;;
		*)
			echo 'Internal error!' >&2
			exit 1
		;;
	esac
done

echo 'Remaining arguments:'
for arg; do
	echo "--> '$arg'"
done

case "$1" in
	start)
		startup
	;;
	stop)
		cleanup
	;;
	status)
		status
	;;
	*)
		usage
	;;
esac

