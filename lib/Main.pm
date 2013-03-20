#!/usr/bin/perl -w
package Main;

use Logger::Logger;
use Data::Dumper;
use base 'Exporter';

our @EXPORT=qw($config $sysconfig $logger);

if ( ! -f "/etc/netclient/logs.yml" or ! -f "/etc/netclient/config.yml" ) {
        print STDERR "Can't load configuration files!";
        exit 1;
}
#Грузим конфиг с данными по логам для передачи
$config = YAML::Tiny->read("/etc/netclient/logs.yml");
#Грузим основной конфиг
our $sysconfig = YAML::Tiny->read("/etc/netclient/config.yml");

#debug log
$debug_file = $sysconfig->[0]->{'log_file'};
$logger = new Logger::Logger ( $debug_file, 1 ) or die "Can't create object: Logger::Logger::Error";

#TODO
sub start_proc
{

#check log files configuration
#if ( check_logs_config() eq 0 ) { return 0; }

return 1;

}

#function lor tail logs in threads
sub send_read_log
{
my $log_data1 = shift;

($name, $local_path, $server, $remote_path) = split(/::/, $log_data1);

$socket = new IO::Socket::INET (
PeerHost => $server,
PeerPort => '9999',
Proto => 'udp',
        ) or die "ERROR in Socket Creation : $!\n";


my $file=File::Tail->new(name=>"$local_path/$name", maxinterval=>0.1);

        while (defined($line=$file->read)) {
		#добавляем разделитель
                $send_text = $name . ":::" . $remote_path . ":::" . $line;
                $socket->send($send_text);
                if ( $sysconfig->[0]->{'debug'} eq 1 ) {
                        $logger->debug_message("Send data: $line to $name");
                }
        }

}

#perl...
1;
