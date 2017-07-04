use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::Object;

# ABSTRACT: JSON Schema Object Instance

# AUTHORITY

# VERSION

use Scalar::Util qw/blessed/;
use overload (
    '==' => \&_equal
);

sub new {
    # my ($class, $value) = @_;
    bless($_[1], __PACKAGE__)
}

sub _equal {
    # my ($s1, $s2) = @_;

    my $b1 = blessed($_[0]) // '';
    my $b2 = blessed($_[1]) // '';

    return 0 unless $b1 && $b2 && ($b1 eq __PACKAGE__);

    my ($h1, $h2) = ($$_[0], $$_[1]);
    my @keys1 = keys %{$h1};
    my @keys2 = keys %{$h2};
    #
    # Same number of keys
    #
    my $max_keys1 = $#keys1;
    my $max_keys2 = $#keys2;
    my $cmp = $max_keys1 <=> $max_keys2;
    return $cmp if $cmp;
    #
    # Same key values
    #
    foreach (@keys1) {
        $cmp = $h1->{$_} <=> $h2->{$_};
        return $cmp if $cmp
    }
    return 0
}

1;
