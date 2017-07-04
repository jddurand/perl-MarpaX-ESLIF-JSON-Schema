use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::Array;

# ABSTRACT: JSON Schema Array Instance

# AUTHORITY

# VERSION

use MarpaX::ESLIF::JSON::Schema::Instance;
use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => sub { my $rc = _equal(@_); print STDERR $rc ? "ARRAY OK\n" : "ARRAY DIFFER\n"; $rc },
              'eq'     => sub { my $rc = _equal(@_); print STDERR $rc ? "ARRAY OK\n" : "ARRAY DIFFER\n"; $rc }
             );

sub new {
    # my ($class, $value) = @_;

    bless(\$_[1], __PACKAGE__)
}

sub _stringify {
  return
    '['
    .
    join(',', @{${$_[0]}})
    .
    ']'
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
  # Array instances are blessing a reference to an array
  #
  my ($a1, $a2) = (${$self[0]}, ${$self[1]});
  #
  # No need to compare if not the same number of elements
  #
  return 0 unless $#{$a1} == $#{$a2};
  #
  # Compare elements
  #
  map {
    if ($a1->[$_] != $a2->[$_]) {
      use Data::Dumper;
      use Scalar::Util qw/blessed/;
      print STDERR "blessed(\$a1->[$_]) = " . (blessed($a1->[$_]) // '<undef>') . "\n";
      print STDERR "blessed(\$a2->[$_]) = " . (blessed($a2->[$_]) // '<undef>') . "\n";
      # print STDERR Dumper([$a1->[$_], $a2->[$_]]);
    }
    return 0 unless $a1->[$_] == $a2->[$_]
  } (0..$#{$a1});
  #
  # Ok
  #
  return 1
}

1;
