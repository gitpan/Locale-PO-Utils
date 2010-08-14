#!perl -T

use strict;
use warnings;

use Test::More tests => 4 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

is_deeply(
    [ $obj->expand_gettext() ],
    [ undef ],
    'undef',
);

$obj->set_numeric_code( sub {
    my $value = shift;

    defined $value
        or return $value;
    while ( $value =~ s{(\d+) (\d{3})}{$1,$2}xms ) {}
    $value =~ tr{.,}{,.};

    return $value;
});
eq_or_diff(
    $obj->expand_gettext(
        '{a} {b} {c} {d}',
        a => 'a',
        b => 2,
        c => '3234567.890',
        d => 4_234_567.890,
    ),
    'a 2 3.234.567,890 4.234.567,89',
    'numeric',
);
$obj->clear_numeric_code();

eq_or_diff(
    $obj->expand_gettext(
        'foo {plus} bar {plus} baz = {num} items {undef}',
        plus  => q{+},
        num   => 3,
        undef => undef,
    ),
    'foo + bar + baz = 3 items {undef}',
    'object method',
);