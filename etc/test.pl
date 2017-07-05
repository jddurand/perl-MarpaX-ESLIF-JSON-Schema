#!env perl
use strict;
use warnings FATAL => 'all';

use IO::Handle;
use File::Slurp;
use Log::Log4perl qw/:easy/;
use Log::Any::Adapter;
use Log::Any qw/$log/;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;

autoflush STDOUT 1;
autoflush STDERR 1;

#
# Init log
#
our $defaultLog4perlConf = '
        log4perl.rootLogger              = TRACE, Screen
        log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr  = 0
        log4perl.appender.Screen.layout  = PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
        ';
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');
use MarpaX::ESLIF::JSON::Schema;

my $schema_location = shift;
my $schema = MarpaX::ESLIF::JSON::Schema->new(read_file($schema_location), logger => $log);
while (@ARGV) {
    my $input = shift;
    print "Validating $input against $schema_location\n";
}

exit(EXIT_SUCCESS);
