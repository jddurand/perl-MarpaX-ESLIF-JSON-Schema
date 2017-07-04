use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema;

# ABSTRACT: JSON Schema

# AUTHORITY

# VERSION

use MarpaX::ESLIF::JSON::Schema::Instance;
use Carp qw/croak/;
use Scalar::Util qw/blessed/;
use overload        (
    '<=>' => \&_equal,
    'cmp' => \&_equal
);

sub new {
    my ($class, $input, %options) = @_;

    #
    # A schema it itself an instance, with the restriction that
    # it HAS to be an object or a boolean
    #
    my $instance = MarpaX::ESLIF::JSON::Schema::Instance->new($input, %options);
    croak "JSON Schema must be an object or a boolean, got type " . $instance->type unless $instance->is_Object || $instance->is_Boolean;

    return bless({ instance => $instance }, __PACKAGE__)
}

sub _equal {
    my ($s1, $s2, $inverted) = @_;

    my $b1 = blessed($s1) // '';
    my $b2 = blessed($s2) // '';
    #
    # No point to compare if these are not two MarpaX::ESLIF::JSON::Schema::Instance instances
    #
    return 0 unless (($b1 eq __PACKAGE__) or ($b2 eq __PACKAGE__));
    #
    # Schema comparison is an instance comparison
    #
    return $inverted ? $s2->{instance} <=> $s1->{instance} : $s1->{instance} <=> $s2->{instance}
}

1;
