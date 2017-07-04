use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema::Instance;

# ABSTRACT: JSON Schema Instance

# AUTHORITY

# VERSION

use Carp qw/croak/;
use Scalar::Util qw/reftype blessed/;
use MarpaX::ESLIF::ECMA404;
use MarpaX::ESLIF::JSON::Schema::Instance::String;
use MarpaX::ESLIF::JSON::Schema::Instance::Number;
use MarpaX::ESLIF::JSON::Schema::Instance::Object;
use MarpaX::ESLIF::JSON::Schema::Instance::Array;
use MarpaX::ESLIF::JSON::Schema::Instance::True;
use MarpaX::ESLIF::JSON::Schema::Instance::False;
use MarpaX::ESLIF::JSON::Schema::Instance::Null;
use overload (
              fallback => 1,
              '""'     => \&_stringify,
              '=='     => \&_equal,
              'eq'     => \&_equal
             );

#
# We want to explicitely type the JSON types
#
our $_BNF = $MarpaX::ESLIF::ECMA404::_BNF;
$_BNF =~ s/^\s*value\s*::=\s*string\b/$& action => MarpaX::ESLIF::JSON::Schema::Instance::_json_string #/sm;
$_BNF =~ s/^\s*\|\s*number\b/$&          action => MarpaX::ESLIF::JSON::Schema::Instance::_json_number #/sm;
$_BNF =~ s/^\s*\|\s*object\b/$&          action => MarpaX::ESLIF::JSON::Schema::Instance::_json_object #/sm;
$_BNF =~ s/^\s*\|\s*array\b/$&           action => MarpaX::ESLIF::JSON::Schema::Instance::_json_array #/sm;
$_BNF =~ s/^\s*\|\s*'true'/$&            action => MarpaX::ESLIF::JSON::Schema::Instance::_json_true #/sm;
$_BNF =~ s/^\s*\|\s*'false'/$&           action => MarpaX::ESLIF::JSON::Schema::Instance::_json_false #/sm;
$_BNF =~ s/^\s*\|\s*'null'/$&            action => MarpaX::ESLIF::JSON::Schema::Instance::_json_null #/sm;

sub new {
    my ($class, $input, %options) = @_;

    my $encoding = delete $options{encoding};

    local $MarpaX::ESLIF::ECMA404::_BNF = $_BNF;
    my $parser = MarpaX::ESLIF::ECMA404->new(
        %options,
        #
        # A JSON document trying to define two properties with the same key is undefined,
        # so we say this is illegal to have duplicate keys.
        #
        disallow_dupkeys => 1
        );
    my $decode = $parser->decode($input, $encoding);
    croak 'JSON parsing failed' unless defined $decode;

    bless(\$decode, __PACKAGE__)
}

sub _stringify {
    #
    # MarpaX::ESLIF::JSON::Schema::Instance::.* stringification
    #
    return ${$_[0]}
}

sub _equal {
  # my ($s1, $s2) = @_;

  #
  # All the arguments must be of type MarpaX::ESLIF::JSON::Schema::Instance
  #
  my @self;
  foreach ($_[0], $_[1]) {
    push(@self, ((blessed($_) // '') =~ /^MarpaX::ESLIF::JSON::Schema::Instance$/)
         ?
         $_
         :
         eval { MarpaX::ESLIF::JSON::Schema::Instance->new($_) }
        );
    return 0 unless defined $self[-1]
  }
  #
  # Compare using overload
  #
  return ${$self[0]} == ${$self[1]}
}

sub is_String  { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::String' }
sub is_Number  { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::Number' }
sub is_Object  { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::Object' }
sub is_Array   { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::Array' }
sub is_True    { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::True' }
sub is_False   { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::False' }
sub is_Null    { $_[0]->type eq 'MarpaX::ESLIF::JSON::Schema::Instance::Null' }
sub is_Boolean { $_[0]->is_True || $_[0]->is_False }
sub type       { blessed(${$_[0]}) }
sub value      { ${$_[0]} }

# ----------------------
# Parser value callbacks
# ----------------------
sub _json_string {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::String->new($_[1])
}

sub _json_number {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::Number->new($_[1])
}

sub _json_object {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::Object->new($_[1])
}

sub _json_array {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::Array->new($_[1])
}

sub _json_true {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::True->new()
}

sub _json_false {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::False->new()
}

sub _json_null {
  # my ($self, $value) = @_;
  MarpaX::ESLIF::JSON::Schema::Instance::Null->new()
}

1;
