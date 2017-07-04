use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::False;

# ABSTRACT: JSON Schema False Instance

# AUTHORITY

# VERSION

use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => sub { my $rc = _equal(@_); print STDERR $rc ? "FALSE OK\n" : "FALSE DIFFER\n"; $rc },
              'eq'     => sub { my $rc = _equal(@_); print STDERR $rc ? "FALSE OK\n" : "FALSE DIFFER\n"; $rc }
             );

sub new {
    # my ($class, $value) = @_;

    bless([], __PACKAGE__)
}

sub _stringify {
  return 'false'
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
  # Ok
  #
  return 1
}

1;
