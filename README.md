# nagios-plugins
just some basic nagios plugin

### ZFS check for linux

#### example output
```
# /usr/lib/nagios/plugins/check_zfs # one pool
OK storage-02(ONLINE 10.3T/87T),storage-03(ONLINE 75.6T/87T),storage-81(ONLINE 1.00T/87T)
# resilver example
WARNING storage-02(ONLINE 11.1T/87T),storage-03(RESILVER 18.53%,223M/s,82h51m),storage-81(ONLINE 1.00T/87T)
# /usr/lib/nagios/plugins/check_zfs # multiple storage pool
OK storage-03(ONLINE 118T/390T)
```

#### example cronjob
```
* * * * * root /usr/bin/perl /usr/lib/nagios/plugins/check_zfs |xargs echo $(hostname) pass_Raid| xargs passive_check_send
```

#### integrating with NRPE
The Nagios Remote Plugin Executor can run this script upon request from a Nagios
monitor server. The NRPE daemon runs as an unprivileged user (typically named
`nrpe` or `nagios`) although the zfs/zpool commands require superuser privileges.

Included is an example configuration file that can be placed in `/etc/sudoers.d'.
It will allow any non-root user to run the "read-only" `zfs` and `zpool` commands
while preventing the execution of commands that modify filesystems and storage
pools.

A typical NRPE configuration files is placed in `/etc/nrpe.d` on RHEL-derived
platforms and `/etc/nagios/nrpe.d` on Debian derivatives. These files point to
nagios plugins for execution. For example
```
command[check_zpool]=/usr/lib/nagios/plugins/check_zpool
```
On RHEL derivatives, the plugins are stored under `/usr/lib64`. The nagios
monitor must then be configured to check the host using this command. The
example below is not exact but intended to provide the outline. Please
examine [nagios documentation](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html)
for the full range of nagios object definitions and their options.
```
define service {
  use                    generic-service
  service_description    zpool-health
  hostgroup_name         storage
  ...
  check_command          check_nrpe_1arg!check_zpool
}
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

### Check bacula job status - SQL
/usr/lib/nagios/plugins/check_bacula

#### example output
```
# /usr/lib/nagios/plugins/check_bacula
pass_Bacula CRITICAL: Success: 75, Failed: 3 (Job1AutoMysqlBackupDaily, Job2AutoMysqlBackupDaily, Job3BackupDaily)
```

#### example cronjob
same as zfs

