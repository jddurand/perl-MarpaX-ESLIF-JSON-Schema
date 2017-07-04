use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance::String;

# ABSTRACT: JSON Schema String Instance

# AUTHORITY

# VERSION

use Scalar::Util qw/blessed/;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => sub { my $rc = _equal(@_); print STDERR $rc ? "STRING OK\n" : "STRING DIFFER\n"; $rc },
              'eq'     => sub { my $rc = _equal(@_); print STDERR $rc ? "STRING OK\n" : "STRING DIFFER\n"; $rc }
             );

sub new {
    # my ($class, $value) = @_;

    bless(\$_[1], __PACKAGE__)
}

sub _stringify {
  return ${$_[0]}
}

sub _equal {
  # my ($s1, $s2) = @_;

  #
  # All the arguments must be of type MarpaX::ESLIF::JSON::Schema::Instance::
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
  # They must be equal code point to code point
  #
  return ${$_[0]} eq ${$_[1]}
}

1;
