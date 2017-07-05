use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::Object;

# ABSTRACT: JSON Schema Object Instance

# AUTHORITY

# VERSION

use MarpaX::ESLIF::JSON::Schema::Instance;
use MarpaX::ESLIF::JSON::Schema::Instance::String;
use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => \&_equal,
              'eq'     => \&_equal
             );

sub new {
  # my ($class, $value) = @_;

  return bless(\$_[1], __PACKAGE__)
}

sub _stringify {
    #
    # Take care, in perl a has key is always a pure perl string
    # (perl automatically stringifies). In order to get a JSON string
    # we have to get it back as a MarpaX::ESLIF::JSON::Schema::Instance::String.
    #
  return
    '{'
    .
    join(',', map { join('=>', MarpaX::ESLIF::JSON::Schema::Instance::String->new($_), ${$_[0]}->{$_}) } sort keys %{${$_[0]}})
    .
    '}'
}

sub _equal {
  # my ($s1, $s2) = @_;

  #
  # All the arguments must be of type MarpaX::ESLIF::JSON::Schema::Instance::.*
  #
  my @self;
  foreach ($_[0], $_[1]) {
    push(@self, ((blessed($_) // '') =~ /^MarpaX::ESLIF::JSON::Schema::Instance::/)
         ?
         $_
         :
         eval { MarpaX::ESLIF::JSON::Schema::Instance->new($_)->value }
        );
    return 0 unless defined $self[-1]
  }
  #
  # They must be both __PACKAGE__ instances
  #
  return 0 unless (blessed($self[0]) eq __PACKAGE__) && (blessed($self[1]) eq __PACKAGE__);
  #
  # Object instances are blessing a reference to a hash
  #
  my ($h1, $h2) = (${$self[0]}, ${$self[1]});
  #
  # No need to compare if not the same number of keys
  #
  my %keys1 = map { $_ => 1 } keys %{$h1};
  my %keys2 = map { $_ => 1 } keys %{$h2};
  return 0 unless keys %keys1 == keys %keys2; # Scalar context
  #
  # Compare keys
  #
  map { return 0 unless exists($keys2{$_}); delete $keys2{$_}  } keys %keys1;
  return 0 if %keys2; # Since there is the same number of keys, if keys2 is not fully consumed then keys differ
  #
  # Compare values
  #
  map { return 0 unless $h1->{$_} == $h2->{$_} } keys %keys1;
  #
  # Ok
  #
  return 1
}

1;
