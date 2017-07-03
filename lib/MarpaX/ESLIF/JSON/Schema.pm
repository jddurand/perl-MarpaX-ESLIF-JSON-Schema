use strict;
use warnings FATAL => 'all';

package MarpaX::ESLIF::JSON::Schema;

# ABSTRACT: JSON Schema implementation using MarpaX::ESLIF::ECMA404

use Carp qw/croak/;
use Scalar::Util qw/reftype/;
use MarpaX::ESLIF::ECMA404;
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
    my ($class, $input, %options) = @_;

    my $encoding = delete $options{encoding};
    #
    # Ok if it autovivifies $options->{logger}
    #
    my $self = bless { logger => $options{logger} }, $class;

    local $MarpaX::ESLIF::ECMA404::_BNF = $_BNF;
    $self->{parser} = MarpaX::ESLIF::ECMA404->new(
        %options,
        #
        # A JSON document trying to define two properties with the same key is undefined,
        # so we say this is illegal.
        #
        disallow_dupkeys => 1
        );
    #
    # A schema it itself an instance, with the restriction that
    # it HAS to be an object or a boolean
    #
    my $schema = $self->{schema} = $self->instance($input, $encoding);
    my $type = $schema->{type};
    $self->_ok((grep { $type eq $_ } qw/boolean object/),
               1, # croak
               "JSON Schema must be an object or a boolean, got type %s",
               $type);

    return $self
}

sub schema {
    my ($self) = @_;

    return $self->{schema}
}

sub instance {
  my ($self, $input, $encoding) = @_;

  my $instance = $self->{parser}->decode($input, $encoding);

  $self->_ok(defined($instance),
             1, # croak
             'JSON Schema parsing failed');
  return $instance
}

sub eq {
    my ($self, $schema) = @_;
    return $self->_json_eq($self->{schema}, $schema)
}

# --------------------------------------------------------------
# Generic routine eventually logging and returning true or false
# --------------------------------------------------------------
sub _ok {
    my ($self, $condition, $croak, $format, @rest) = @_;

    if (! $condition) {
        my $logger = $self->{logger};
        $logger->errorf($format, @rest) if defined($logger);
        return 0
    }

    return 1
}

# -------------------------
# Generic equality callback
# -------------------------
sub _json_eq {
    my ($self, $wanted, $got) = @_;

    return 0 unless my $type = $self->_json_type_eq($wanted, $got);
    #
    # Null type have no equality callback
    #
    return 1 if $type eq 'null';

    my $callback_eq = "_json_${type}_eq";
    return $self->$callback_eq($wanted, $got)
}

# -------------
# Type equality
# -------------
sub _json_type_eq {
    my ($self, $wanted, $got) = @_;

    my $wantedReftype = reftype($wanted) // '';
    my $gotReftype    = reftype($got)    // '';

    return unless $self->_ok($wantedReftype eq 'HASH',
                             0, # croak
                             'First argument reftype must be HASH, got %s',  $wantedReftype);
    return unless $self->_ok($gotReftype eq 'HASH',
                             0, # croak
                             'Second argument reftype must be HASH, got %s', $gotReftype);

    my $wantedType = $wanted->{type} // '';
    my $gotType    = $got->{type}    // '';

    #
    # For convenience we return the type instead of a boolean
    #
    return $self->_ok($wantedType eq $gotType,
                      0, # croak
                      'Excepting type %s, got %s',
                      $wantedType,
                      $gotType) ? $wantedType : undef
}

# ---------------
# String equality
# ---------------
sub _json_string_eq {
    my ($self, $wanted, $got) = @_;

    my $wantedValue = $wanted->{value};
    my $gotValue = $got->{value};
    return $self->_ok($wantedValue eq $gotValue,
                      0, # croak
                      'Excepting string "%s", got "%s"',
                      $wantedValue,
                      $gotValue)
}

# ---------------
# Number equality
# ---------------
sub _json_number_eq {
    my ($self, $wanted, $got) = @_;

    my $wantedValue = $wanted->{value};
    my $gotValue = $got->{value};
    return $self->_ok($wantedValue == $gotValue,
                      0, # croak
                      'Excepting number %s, got %s',
                      $wantedValue,
                      $gotValue)
}

# ---------------
# Object equality
# ---------------
sub _json_object_eq {
    my ($self, $wanted, $got) = @_;

    foreach my $key (keys %{$wanted->{value}}) {
        return unless
            $self->_ok(exists($got->{value}->{$key}),
                       0, # croak
                       'Excepting key "%s" that does not exist',
                       $key)
            ||
            $self->_json_eq($wanted->{value}->{$key},
                            $got->{value}->{$key})
    }
    return 1
}

# --------------
# Array equality
# --------------
sub _json_array_eq {
    my ($self, $wanted, $got) = @_;

    my $wantedRef = $wanted->{value};
    my $gotRef = $got->{value};

    my $wantedNbElements = scalar(@{$wantedRef});
    my $gotNbElements = scalar(@{$gotRef});

    return unless $self->_ok($wantedNbElements == $gotNbElements,
                             0, # croak
                             'Excepting %d elements, got %d',
                             $wantedNbElements,
                             $gotNbElements);
    my $indice;
    while ($indice++ < $gotNbElements) {
        return unless $self->_json_eq($wantedRef->[$indice], $gotRef->[$indice])
    }
    return 1
}

# -------------
# True equality
# -------------
sub _json_true_eq {
    return 1
}

# --------------
# False equality
# --------------
sub _json_false_eq {
    return 0
}

# -------------
# Null equality
# -------------
sub _json_null_eq {
    croak '_json_null_eq should never be called'
}

# ----------------------
# Parser value callbacks
# ----------------------
sub _json_string { my ($self, $value) = @_; return { type => 'string',  value => $value } }
sub _json_number { my ($self, $value) = @_; return { type => 'number',  value => $value } }
sub _json_object { my ($self, $value) = @_; return { type => 'object',  value => $value } }
sub _json_array  { my ($self, $value) = @_; return { type => 'array',   value => $value } }
sub _json_true   { my ($self, $value) = @_; return { type => 'boolean', value => $value } }
sub _json_false  { my ($self, $value) = @_; return { type => 'boolean', value => $value } }
sub _json_null   { my ($self, $value) = @_; return { type => 'null',    value => $value } }

1;
