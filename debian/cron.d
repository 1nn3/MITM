#
# Regular cron jobs for the mitm package
#

# maintenance
0 4	* * *	root	[ -x /usr/bin/mitm_maintenance ] && /usr/bin/mitm_maintenance
0 0	1 * *	root	/usr/bin/dsniffd-cleanup

