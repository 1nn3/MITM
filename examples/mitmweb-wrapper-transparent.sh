#!/usr/bin/env sh

#set -x
set -e

export LANG="C"
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

usage () {
	cat <<! 1>&2
mitmproxy unter Kali
Usage: $0 [-i interface] <start|stop|status> ;-)
Die Zertifikate befinden sich unter ~/.mitmproxy
!
	exit 1
}
startup () {
	daemonize -e $log -o $log -c . -l $mitmproxy_pid -p $mitmproxy_pid -u root /usr/bin/mitmproxy --mode transparent

	sysctl -w net.ipv4.conf.$if.forwarding=1
	sysctl -w net.ipv6.conf.$if.forwarding=1

	iptables -t nat -A PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080

	ip6tables -t nat -A PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080
}
cleanup () {
	pkill -F $mitmproxy_pid

	sysctl -w net.ipv4.conf.$if.forwarding=0
	sysctl -w net.ipv6.conf.$if.forwarding=0

	iptables -t nat -D PREROUTING 1
	ip6tables -t nat -D PREROUTING 1
}
status () {
	pgrep --pidfile $mitmproxy_pid
	tail $log
}

cd ~/.mitmproxy/ || exit

name="`basename "$0"`"
mitmproxy_pid="$name.pid"
mitmproxy_log="$name.log"

# check write permissions amongst other things
touch $mitmproxy_pid $mitmproxy_log

# Interface unter Kali i.d.R. eth0 und entsprechendes Gateway
#if=${if:-`ip -br a | awk '$2=="UP" && $1!="lo" {print $1; exit}'`}
con=${CONNECTION:-`nmcli -g uuid,state connection | awk -F ':' '$2=="activated" {print $1; exit}'`}
if=`nmcli -t connection show $con | sed -n -E "/^GENERAL\.DEVICES:/s///p"`

TEMP=$(getopt -o 'hi:' --long 'help,interface:' -n "$0" -- "$@")

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

if [ ! $if ]; then
	echo "Konnte Interface($if) nicht ermitteln :-(" 1>&2
	exit 1
else
	echo "Interface($if) ermittelt :-)"
fi

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
		echo "Usage: $0 <start|stop|status> ;-)" 1>&2
		exit 1
	;;
esac

