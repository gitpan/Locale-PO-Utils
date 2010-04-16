#!perl -T

use strict;
use warnings;

use Carp qw(croak);
use Test::More tests => 12 + 1;
use Test::NoWarnings;
use Test::Exception;

BEGIN {
    use_ok('Locale::PO::Utils');
}

throws_ok(
    sub {
        Locale::PO::Utils->new(xxx => 1);
    },
    qr{unknown \s+ attribute .+? xxx}xms,
    'false attribute',
);

my $obj = Locale::PO::Utils->new(
    charset   => 11,
    eol       => 21,
    separator => 31,
);
isa_ok(
    $obj,
    'Locale::PO::Utils',
    'isa',
);

# check getter
is(
    $obj->get_charset(),
    11,
    '11 get_charset',
);
is(
    $obj->get_eol(),
    21,
    '21 get_eol',
);
is(
    $obj->get_separator(),
    31,
    '31 get_separator',
);

# run setter
$obj->set_charset(12);
$obj->set_eol(22);
$obj->set_separator(32);

# read settings back
is(
    $obj->get_charset(),
    12,
    '12 get_charset',
);
is(
    $obj->get_eol(),
    22,
    '22 get_eol',
);
is(
    $obj->get_separator(),
    32,
    '32 get_separator',
);

# check defaults
$obj = Locale::PO::Utils->new();
is(
    $obj->get_charset(),
    'UTF-8',
    'UTF-8 get_charset',
);
is(
    $obj->get_eol(),
    "\n",
    '\n get_eol',
);
is(
    $obj->get_separator(),
    "\n",
    '\n get_separator',
);