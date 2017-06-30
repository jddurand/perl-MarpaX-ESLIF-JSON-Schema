use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema;

# ABSTRACT: JSON Schema implementation using MarpaX::ESLIF::ECMA404

#
# We subclass MarpaX::ESLIF::ECMA404, providing our own grammar with our own actions
#
use parent 'MarpaX::ESLIF::ECMA404';

sub new {
  my ($class, @args) = @_;

  my $_BNF = $MarpaX::ESLIF::ECMA404::_BNF;

  #
  # We want to explicitely type the JSON types
  #
  $_BNF =~ s/^\s*value\s*::=\s*string\b/$& action => MarpaX::ESLIF::JSON::Schema::_json_string #/sm;
  $_BNF =~ s/^\s*\|\s*number\b/$&          action => MarpaX::ESLIF::JSON::Schema::_json_number #/sm;
  $_BNF =~ s/^\s*\|\s*object\b/$&          action => MarpaX::ESLIF::JSON::Schema::_json_object #/sm;
  $_BNF =~ s/^\s*\|\s*array\b/$&           action => MarpaX::ESLIF::JSON::Schema::_json_array #/sm;
  $_BNF =~ s/^\s*\|\s*'true'/$&            action => MarpaX::ESLIF::JSON::Schema::_json_true #/sm;
  $_BNF =~ s/^\s*\|\s*'false'/$&           action => MarpaX::ESLIF::JSON::Schema::_json_false #/sm;
  $_BNF =~ s/^\s*\|\s*'null'/$&            action => MarpaX::ESLIF::JSON::Schema::_json_null #/sm;

  local $MarpaX::ESLIF::ECMA404::_BNF = $_BNF;
  return $class->SUPER::new(@args);
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
