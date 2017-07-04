use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::Object;

# ABSTRACT: JSON Schema Object Instance

# AUTHORITY

# VERSION

use MarpaX::ESLIF::JSON::Schema::Instance;
use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => sub { my $rc = _equal(@_); print STDERR $rc ? "OBJECT OK\n" : "OBJECT DIFFER\n"; $rc },
              'eq'     => sub { my $rc = _equal(@_); print STDERR $rc ? "OBJECT OK\n" : "OBJECT DIFFER\n"; $rc }
             );

sub new {
  # my ($class, $value) = @_;

  return bless(\$_[1], __PACKAGE__)
}

sub _stringify {
  return
    '{'
    .
    join(',', map { "'$_' => " . ${$_[0]}->{$_} } sort keys %{${$_[0]}})
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
  map { return 0 unless exists($h2->{$_}) } keys %keys1;
  map { return 0 unless exists($h1->{$_}) } keys %keys2;
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
