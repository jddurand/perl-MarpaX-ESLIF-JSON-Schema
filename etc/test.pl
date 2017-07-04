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
local %Data::Scan::Printer::Option = (with_ansicolor => 0, with_deparse => 1);

my $input1 = read_file($ARGV[0]);
my $schema1 = MarpaX::ESLIF::JSON::Schema->new($input1, logger => $log);
exit;
die dspp($schema1);

my $input2 = read_file($ARGV[1] // $ARGV[0]);
my $schema2 = MarpaX::ESLIF::JSON::Schema->new($input2, logger => $log);

if ($schema1 == $schema2) {
  print "Schemas are equal:\n$schema1\n";
  #dspp($schema1);
} else {
  print "Schemas are not equal\n";
  #local %Data::Scan::Printer::Option = (with_ansicolor => 0, with_deparse => 1);
  #dspp($schema1);
  #print "\n";
  #dspp($schema2);
  #print "\n";
}

exit(0);
