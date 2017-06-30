use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema;

# ABSTRACT: JSON Schema implementation using MarpaX::ESLIF::ECMA404

use Carp qw/croak/;
use Scalar::Util qw/blessed/;
use parent qw/MarpaX::ESLIF::ECMA404/;
#
# We want to explicitely type the JSON types
#
our $_BNF = $MarpaX::ESLIF::ECMA404::_BNF;
$_BNF =~ s/^\s*value\s*::=\s*string\b/$& action => MarpaX::ESLIF::JSON::Schema::_json_string #/sm;
$_BNF =~ s/^\s*\|\s*number\b/$&          action => MarpaX::ESLIF::JSON::Schema::_json_number #/sm;
$_BNF =~ s/^\s*\|\s*object\b/$&          action => MarpaX::ESLIF::JSON::Schema::_json_object #/sm;
$_BNF =~ s/^\s*\|\s*array\b/$&           action => MarpaX::ESLIF::JSON::Schema::_json_array #/sm;
$_BNF =~ s/^\s*\|\s*'true'/$&            action => MarpaX::ESLIF::JSON::Schema::_json_true #/sm;
$_BNF =~ s/^\s*\|\s*'false'/$&           action => MarpaX::ESLIF::JSON::Schema::_json_false #/sm;
$_BNF =~ s/^\s*\|\s*'null'/$&            action => MarpaX::ESLIF::JSON::Schema::_json_null #/sm;

sub new {
  my ($class, %options) = @_;

  local $MarpaX::ESLIF::ECMA404::_BNF = $_BNF;
  $class->SUPER::new(%options,
                     #
                     # A JSON document trying to define two properties with the same key is undefined,
                     # so we say this is illegal.
                     #
                     disallow_dupkeys => 1
                    )
}

sub schema {
  my ($self, @args) = @_;
  #
  # A schema it itself an instance, with the restriction that
  # it HAS to be an object or a boolean
  #
  my $schema = $self->instance(@args);
  my $type = blessed(${$schema});
  $type =~ s/.*:://;
  croak "JSON Schema must be an object or a boolean, got type $type" unless grep { $type eq $_ } qw/boolean object/;

  return $schema
}

sub instance {
  my ($self, @args) = @_;

  my $decode = $self->SUPER::decode(@args);
  #
  # Because we overwrote all possible RHSs of a JSON value in the grammar,
  # we are guaranteed that there the value is blessed, unless parsing failed
  #
  croak 'JSON Schema parsing failed' unless defined $decode;
  #
  # Because $self is reusable, we do a lazy typing saying by blessing
  # the decode result - a bad programmer would bless to the same value outside
  # of this package -;
  #
  return bless(\$decode, 'MarpaX::ESLIF::JSON::Schema::Instance')
}


sub _equal {
  my ($self, $wanted, $got, @context) = @_;
  my $context = join('.', @context);
  #
  # Check the types
  #
  my ($wantedType, $gotType) = (blessed($wanted), blessed($got));
  croak "At context $context, got type $gotType instead of $wantedType" unless $gotType eq $wantedType;
  #
  # Check for values
  #
  my ($wantedValue, $gotValue) = ($$wanted, $$got);
  $gotType =~ s/.*:://;
  if ($gotType eq 'string') {
    #
    # String
    #
    return "At context $context, got string $gotValue instead of $wantedValue" unless $gotValue eq $wantedValue;
  } elsif ($gotType eq 'number') {
    #
    # Number
    #
    return "At context $context, got number $gotValue instead of $wantedValue" unless $gotValue == $wantedValue; # bignum overwrites if needed
  } elsif ($gotType eq 'object') {
    #
    # Object
    #
    foreach my $key (keys %{$wantedValue}) {
      #
      # Check each property key
      #
      croak "At context $context, property $key is missing" unless exists $gotValue->{$key};
      #
      # Check each property value
      #
      push(@context, $key);
      $self->_equal($wantedValue->{$key}, $gotValue->{$key}, @context);
      pop(@context)
    }
  } elsif ($gotType eq 'array') {
    #
    # Array
    #
    my $wantedArraySize = $#{$wantedValue};
    my $gotArraySize = $#{$gotValue};
    croak "At context $context, got array $gotArraySize instead of $wantedArraySize" unless $gotArraySize == $wantedArraySize;
    foreach my $indice (0..$wantedArraySize) { # No op if it is -1
      push(@context, $indice);
      $self->_equal($wantedValue->[$indice], $gotValue->[$indice], @context);
      pop(@context)
    }
  } elsif ($gotType eq 'true') {  # No op, type check is enough
  } elsif ($gotType eq 'false') {  # No op, type check is enough
  } elsif ($gotType eq 'null') {  # No op, type check is enough
  } else { # Should never happen
    croak "At context $context, unknown type $gotType"
  }
}

sub equal {
  my ($self, $value1, $value2) = @_;
  foreach ($value1, $value2) {
    my $blessed = blessed($_);
    croak "Parameter must be blessed" unless $blessed;
    croak "Parameter must be blessed to MarpaX::ESLIF::JSON::Schema::Instance" unless $blessed eq 'MarpaX::ESLIF::JSON::Schema::Instance';
    $self->_equal($value1, $value2)
  }
}

sub _json_type_and_value {
  my ($type, $value) = @_;
  return bless(\$value, "MarpaX::ESLIF::JSON::Schema::Type::$type")
}

sub _json_string {
  my ($self, $value) = @_;
  return _json_type_and_value('string', $value)
}

sub _json_number {
  my ($self, $value) = @_;
  return _json_type_and_value('number', $value)
}

sub _json_object {
  my ($self, $value) = @_;
  return _json_type_and_value('object', $value)
}

sub _json_array {
  my ($self, $value) = @_;
  return _json_type_and_value('array', $value)
}

sub _json_true {
  my ($self, $value) = @_;
  return _json_type_and_value('boolean', $value)
}

sub _json_false {
  my ($self, $value) = @_;
  return _json_type_and_value('boolean', $value)
}

sub _json_null {
  my ($self, $value) = @_;
  return _json_type_and_value('null', undef)
}

1;
