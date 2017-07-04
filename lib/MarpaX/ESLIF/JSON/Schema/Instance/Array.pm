use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::Array;

# ABSTRACT: JSON Schema Array Instance

# AUTHORITY

# VERSION

use Scalar::Util qw/blessed/;
use overload (
    '==' => \&_equal
);

sub new {
    # my ($class, $value) = @_;
    print STDERR "JDD Array\n";
    bless($_[1], __PACKAGE__)
}

sub _equal {
    # my ($s1, $s2) = @_;

    my $b1 = blessed($_[0]) // '';
    my $b2 = blessed($_[1]) // '';

    return 0 unless $b1 && $b2 && ($b1 eq __PACKAGE__);

    my ($a1, $a2) = ($$_[0], $$_[1]);
    #
    # Same number of elements
    #
    my $max1 = $#{$a1};
    my $max2 = $#{$a2};
    my $cmp = $max1 <=> $max2;
    return $cmp if $cmp;
    #
    # Same values
    #
    foreach (0..$max1) {
        $cmp = $a1->[$_] <=> $a2->[$_];
        return $cmp if $cmp
    }
    return 0
}

1;
