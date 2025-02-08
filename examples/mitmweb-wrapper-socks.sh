#!/usr/bin/env sh

#set -x
set -e

export LANG="C"
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

usage () {
	cat <<! 1>&2
mitmproxy unter Kali
Usage: $0 <start|stop|status> ;-)
Die Zertifikate befinden sich unter ~/.mitmproxy
!
	exit 1
}
startup () {
	iptables -t nat -A PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080
	iptables -t nat -A PREROUTING -i $if -m multiport -p udp --dports 53 -j REDIRECT --to-port 53

	ip6tables -t nat -A PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080
	ip6tables -t nat -A PREROUTING -i $if -m multiport -p udp --dports 53 -j REDIRECT --to-port 53

	daemonize -e $log -o $log -c . -l $mitmproxy_pid -p $mitmproxy_pid /usr/bin/mitmweb --mode socks5
}
cleanup () {
	pkill -F $mitmproxy_pid

	iptables -t nat -D PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080
	iptables -t nat -D PREROUTING -i $if -m multiport -p udp --dports 53 -j REDIRECT --to-port 53

	ip6tables -t nat -D PREROUTING -i $if -m multiport -p tcp --dports 80,443 -j REDIRECT --to-port 8080
	ip6tables -t nat -D PREROUTING -i $if -m multiport -p udp --dports 53 -j REDIRECT --to-port 53
}
status () {
	pgrep --pidfile $mitmproxy_pid
	tail $mitmproxy_log
}

cd ~/.mitmproxy/ || exit

name="`basename "$0"`"
mitmproxy_pid="$name.pid"
mitmproxy_log="$name.log"

# check write permissions amongst other things
touch $mitmproxy_pid $mitmproxy_log

TEMP=$(getopt -o 'h' --long 'help' -n "$0" -- "$@")

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
		echo "Usage: $0 <start|stop|status> ;-)" >&2
		exit 1
	;;
esac

