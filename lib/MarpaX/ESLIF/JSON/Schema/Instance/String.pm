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
              '=='     => \&_equal,
              'eq'     => \&_equal
             );

sub new {
    # my ($class, $value) = @_;

    bless(\$_[1], __PACKAGE__)
}

sub _stringify {
    my $escaped = ${$_[0]};

    $escaped =~ s/"/\\"/g;
    $escaped =~ s/\\/\\\\/g;
    $escaped =~ s/\//\\\//g;  # Not strictly needed but recommended
    $escaped =~ s/\x{08}/\\b/g;
    $escaped =~ s/\x{0C}/\\f/g;
    $escaped =~ s/\x{0A}/\\n/g;
    $escaped =~ s/\x{0D}/\\r/g;
    $escaped =~ s/\x{09}/\\t/g;
    #
    # We choose to keep explicitely only the printable ASCII characters (i.e. [ ~])
    #
    $escaped =~ s#[^\x{20}-\x{7E}]#my $ord = ord($&); if ($ord <= 0x010000) { sprintf('\u%04X', $ord) } else { $ord -= 0x010000; sprintf('\u%04X\u%04X', $ord/0x400 + 0xD800, $ord%0x400 + 0xDC00) }#eg;

    return "\"$escaped\""
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
