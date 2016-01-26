# nagios-plugins
just some basic nagios plugin

### ZFS check for linux

#### example output
```
# /usr/lib/nagios/plugins/check_zfs # one pool
OK storage-02(ONLINE 10.3T/87T),storage-03(ONLINE 75.6T/87T),storage-81(ONLINE 1.00T/87T)
# /usr/lib/nagios/plugins/check_zfs # multiple storage pool
OK storage-03(ONLINE 118T/390T)
```

#### example cronjob
```
* * * * * root /usr/bin/perl /usr/lib/nagios/plugins/check_zfs |xargs echo $(hostname) pass_Raid| xargs passive_check_send
```

### Check open filehandles (comparing open filehandles with proc's rlimit nofile) - linux only
/usr/lib/nagios/plugins/check_procs_fh [-w warningpercent] [-c criticalpercent]

#### example output
```
# /usr/lib/nagios/plugins/check_procs_fh -w 1 -c 2
pass_ProcFD CRITICAL: (W:sshd;3148;11/1024), (C:syslog-ng;7486;2004/65536), (W:udevd;1529;11/1024), (W:lldpd;7063;14/1024), (W:rpcbind;6170;12/1024), (C:rpc.mountd;16466;21/1024)
```

#### example cronjob
same as zfs
