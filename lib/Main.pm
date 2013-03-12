#!/usr/bin/perl -w
package Main;

use strict;
use Logger::Logger;
use Data::Dumper;
use base 'Exporter';

our @EXPORT=qw($config $sysconfig);

my $debug_file = "/var/log/netclient.log";
my $logger = new Logger::Logger ( $debug_file, 1 ) or die "Can't create object: Logger::Logger::Error";

if ( ! -f "/etc/netclient/logs.yml" or ! -f "/etc/netclient/config.yml" ) {
	print STDERR "Can't load configuration files!";
	$logger->debug_message("Can't load configuration files!");
	exit 1;
}

our $config = YAML::Tiny->read("/etc/netclient/logs.yml");
our $sysconfig = YAML::Tiny->read("/etc/netclient/config.yml");


sub start_proc
{

#check log files configuration
if ( check_logs_config() eq 0 ) { return 0; }

return 1;

}

sub check_logs_config
{

foreach my $key ( keys $config->[0] ) {
	if ( $config->[0]->{$key}->{'name'} =~ m/\*/ ) {
		next;
	}
	#check log files exists. If any file not exists, exit.
	if ( ! -f "$config->[0]->{$key}->{'local_path'}/$config->[0]->{$key}->{'name'}" ) {
		$logger->debug_message("Log file $config->[0]->{$key}->{'local_path'}/$config->[0]->{$key}->{'name'} does not exists!");
		print STDERR "Log file $config->[0]->{$key}->{'local_path'}/$config->[0]->{$key}->{'name'} does not exists!";
		return 0;
	}
}

return 1;

}
#end check_logs_config function

sub check_system_config
{

return 1;

}

1;

