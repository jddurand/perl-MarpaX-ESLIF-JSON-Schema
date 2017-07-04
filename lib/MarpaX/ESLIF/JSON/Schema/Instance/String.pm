use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::String;

# ABSTRACT: JSON Schema String Instance

# AUTHORITY

# VERSION

use Scalar::Util qw/blessed/;
use overload (
    '==' => \&_equal
);

sub new {
    # my ($class, $value) = @_;
    print STDERR "JDD String\n";
    bless(\$_[1], __PACKAGE__);
}

sub _equal {
    # my ($s1, $s2) = @_;

    my $b1 = blessed($_[0]) // '';
    my $b2 = blessed($_[1]) // '';

    $b1 && $b2 && ($b1 eq __PACKAGE__) && ($$$_[0] eq $$$_[1])
}

1;
