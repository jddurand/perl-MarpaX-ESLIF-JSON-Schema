use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema;

# ABSTRACT: JSON Schema

# AUTHORITY

# VERSION

use MarpaX::ESLIF::JSON::Schema::Instance;
use Carp qw/croak/;
use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => \&_equal,
              'eq'     => \&_equal
             );

sub new {
    my ($class, $input, %options) = @_;

    #
    # A schema it itself an instance, with the restriction that
    # it HAS to be an object or a boolean
    #
    my ($package, $filename, $line) = caller;
    my $instance = MarpaX::ESLIF::JSON::Schema::Instance->new($input, %options);
    croak "A JSON Schema must be an JSON object type, or a JSON boolean type, but parsing gives " . lc($instance->type_base) unless $instance->is_Object || $instance->is_Boolean;

    return bless(\$instance, __PACKAGE__)
}

sub _stringify {
    #
    # MarpaX::ESLIF::JSON::Schema::Instance stringification
    #
    return ${$_[0]}
}

sub _equal {
  # my ($s1, $s2) = @_;

  #
  # All the arguments must be of type MarpaX::ESLIF::JSON::Schema
  #
  my @self;
  foreach ($_[0], $_[1]) {
    push(@self, ((blessed($_) // '') =~ /^MarpaX::ESLIF::JSON::Schema$/)
         ?
         $_
         :
         eval { MarpaX::ESLIF::JSON::Schema->new($_) }
        );
    return 0 unless defined $self[-1]
  }
  #
  # They must be both __PACKAGE__ instances
  #
  return 0 unless (blessed($self[0]) eq __PACKAGE__) && (blessed($self[1]) eq __PACKAGE__);
  #
  # Compare using overload
  #
  return ${$self[0]} == ${$self[1]}
}

1;
