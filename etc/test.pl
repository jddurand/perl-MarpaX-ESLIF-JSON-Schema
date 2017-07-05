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

my $input1 = read_file($ARGV[0]);
my $schema1 = MarpaX::ESLIF::JSON::Schema->new($input1, logger => $log);

my $input2 = read_file($ARGV[1] // $ARGV[0]);
my $schema2 = MarpaX::ESLIF::JSON::Schema->new($input2, logger => $log);

my $cmp = ($schema1 == $schema2);

if ($cmp) {
  print "Schemas are equal:\n";
  print "$schema1\n";
} else {
  print "Schemas are not equal:\n";
  print "$schema1\n";
  print "$schema2\n";
}

exit($cmp ? EXIT_SUCCESS : EXIT_FAILURE);
