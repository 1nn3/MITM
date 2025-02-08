#!/usr/bin/env sh
# NetworkManager dispatcher script
# /etc/NetworkManager/dispatcher.d/99-local-dsniffd

if=$1
action=$2

case $action in
	pre-up)
	;;
	up)
		dsniffd -i $if start
	;;
	pre-down)
	;;
	down)
		dsniffd -i $if stop
	;;
	vpn-pre-up)
	;;
	vpn-up)
	;;
	vpn-pre-down)
	;;
	vpn-down)
	;;
	hostname)
	;;
	dhcp4-change)
	;;
	dhcp6-change)
	;;
	connectivity-change)
	;;
esac

