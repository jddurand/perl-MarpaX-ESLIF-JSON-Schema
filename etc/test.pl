#!env perl
use strict;
use warnings FATAL => 'all';

use File::Slurp;
use Log::Any::Adapter qw/Stderr/;
use Log::Any qw/$log/;
use MarpaX::ESLIF::JSON::Schema;
use Data::Scan::Printer;

my $self = MarpaX::ESLIF::JSON::Schema->new(logger => $log);
my $text = read_file(shift);
my $schema = $self->decode($text);
local %Data::Scan::Printer::Option = (with_ansicolor => 0, with_deparse => 1);
dspp($schema);

exit(0);
