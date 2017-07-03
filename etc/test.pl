#!env perl
use strict;
use warnings FATAL => 'all';

use File::Slurp;
use Log::Log4perl qw/:easy/;
use Log::Any::Adapter;
use Log::Any qw/$log/;
use Data::Dumper;
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
use Data::Scan::Printer;

my $input = read_file(shift);
my $self = MarpaX::ESLIF::JSON::Schema->new($input, logger => $log);
local %Data::Scan::Printer::Option = (with_ansicolor => 0, with_deparse => 1);
my $schema = $self->schema;
# dspp($schema);
$self->eq($schema);

exit(0);
