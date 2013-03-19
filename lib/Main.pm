#!/usr/bin/perl -w
package Main;

use Logger::Logger;
use Data::Dumper;
use base 'Exporter';

our @EXPORT=qw($config $sysconfig $logger $debug_file);

if ( ! -f "/etc/netclient/logs.yml" or ! -f "/etc/netclient/config.yml" ) {
        print STDERR "Can't load configuration files!";
        $logger->debug_message("Can't load configuration files!");
        exit 1;
}

#Грузим конфиг с данными по логам для передачи
our $config = YAML::Tiny->read("/etc/netclient/logs.yml");
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

sub get_logs_from_config
{

foreach $key ( keys $config->[0] ) {

#проверяем что указано как целевой файл
#может быть @file  - обычный текстовый файл 
#или @parrent - регулярное выражение
        #если был указан file
        if ( exists($config->[0]->{$key}->{'file'}) ) {
                #если файл найден на диске
                if ( -f "$config->[0]->{$key}->{'local_path'}/$config->[0]->{$key}->{'file'}" ) {
                        push (@log_data_to_send, "$config->[0]->{$key}->{'file'}::$config->[0]->{$key}->{'local_path'}::$config->[0]->{$key}->{'server'}::$config->[0]->{$key}->{'remote_path'}");
			#$logger->debug_message(@log_data_to_send);
                }
        #если используется регулярка (parrent)
        }
        if ( exists($config->[0]->{$key}->{'parrent'}) ) {
                @files_array = glob "$config->[0]->{$key}->{'local_path'}/$config->[0]->{$key}->{'parrent'}";
                foreach $full_file_name ( @files_array ) {
                        @tmp_name = split("/",$full_file_name);
                        $file_name = @tmp_name[q/-1/];
                        push @log_data_to_send, $file_name . "::$config->[0]->{$key}->{'local_path'}::$config->[0]->{$key}->{'server'}::$config->[0]->{$key}->{'remote_path'}"
                }
        }


}


return @log_data_to_send;

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
                $send_text = $name . ":::" . $remote_path . ":::" . $line;
                $socket->send($send_text);
                if ( $sysconfig->[0]->{'debug'} eq 1 ) {
                        $logger->debug_message("Send data: $line");
                }
        }

}

#perl...
1;
