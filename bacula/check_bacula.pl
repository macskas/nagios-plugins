#!/usr/bin/perl -w

use strict;
use POSIX;
use DBI;


my $sqlDB = "bacula";
my $sqlUsername = "bacula";
my $sqlPassword = "***password***";
my $seconds = 86400;
my $nagios_service = "pass_Bacula";

sub nagios_error()
{
    my $message = shift;
    printf("%s CRITICAL: %s\n", $nagios_service, $message);
    exit(2);
}

sub nagios_ok()
{
    my $message = shift;
    printf("%s OK: %s\n", $nagios_service, $message);
    exit(0);
}

sub collect_bacula_rows()
{
    my $rows_hash = {};
    my $sql_query = "SELECT * FROM Job WHERE StartTime > FROM_UNIXTIME(UNIX_TIMESTAMP()-$seconds) ORDER BY JobId";
    my $dsn = "DBI:mysql:database=$sqlDB;host=localhost";
    my $dbh = DBI->connect( $dsn,$sqlUsername,$sqlPassword, { RaiseError => 0, PrintError => 0 } ) or &nagios_error("Error connecting to: '$dsn': $DBI::errstr");
    my $sth = $dbh->prepare($sql_query) or &nagios_error("Error preparing statemment ". $dbh->errstr);
    $sth->execute or &nagios_error("Execute error ($DBI::errstr)");
    while (my $row = $sth->fetchrow_hashref()) {
    my $n = $row->{'Name'};
    my $jid = $row->{'JobId'};
        if (defined($rows_hash->{"$n"})) {
	    if ($jid > $rows_hash->{"$n"}->{'JobId'}) {
	    $rows_hash->{"$n"} = $row;
	    }
        } else {
	    $rows_hash->{"$n"} = $row;
        }
    }
    return $rows_hash;
}

sub main()
{

    my @failedNames = ();
    my $okCount = 0;
    my $failedCount = 0;

    my $rows_hash = &collect_bacula_rows();
    foreach my $name (keys %{$rows_hash}) {
        my $row = $rows_hash->{"$name"};
        next if ($row->{'JobStatus'} eq 'R');
        
        if ($row->{'JobStatus'} eq 'T') {
	    $okCount++;
        } else {
	    $failedCount++;
        push(@failedNames, $name);
        }
    }

    if ($failedCount > 0) {
    &nagios_error("Success: $okCount, Failed: $failedCount (".join(", ", @failedNames ).")");
    }
    &nagios_ok("Success: $okCount, Failed: $failedCount");
}

&main();
