#!perl -T

use strict;
use warnings;

use Test::More tests => 25 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

eq_or_diff(
    $obj->get_plural_forms(),
    'nplurals=1; plural=0',
    'get plural forms default',
);
eq_or_diff(
    $obj->get_nplurals(),
    1,
    'get nplurals default',
);
eq_or_diff(
    $obj->get_plural_code()->(1),
    0,
    'run plural default code',
);

$obj->set_plural_forms('nplurals=2; plural=n != 1');
$obj->calculate_plural_forms();
eq_or_diff(
    $obj->get_nplurals(),
    2,
    'EN: get nplurals 2',
);
{
    my $plural_code = $obj->get_plural_code();
    my %data = (
        0 => 1,
        1 => 0,
        2 => 1,
    );
    for (sort keys %data) {
        eq_or_diff(
            $plural_code->($_),
            $data{$_},
            "EN: run plural code for $_, expect $data{$_}",
        );
    }
}

# Russian
$obj->set_plural_forms(
    'nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 or n%100>=20) ? 1 : 2)'
);
$obj->calculate_plural_forms();
eq_or_diff(
    $obj->get_nplurals(),
    3,
    'RU: get nplurals 3',
);
{
    my $plural_code = $obj->get_plural_code();
    my %data = (
        0   => 2,
        1   => 0,
        2   => 1,
        5   => 2,
        100 => 2,
        101 => 0,
        102 => 1,
        105 => 2,
        110 => 2,
        111 => 2,
        112 => 2,
        115 => 2,
        120 => 2,
        121 => 0,
        122 => 1,
        125 => 2,
    );
    for (sort keys %data) {
        eq_or_diff(
            $plural_code->($_),
            $data{$_},
            "RU: run plural code for $_, expect $data{$_}",
        );
    }
}

