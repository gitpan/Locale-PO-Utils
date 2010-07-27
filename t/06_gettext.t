#!perl -T

use strict;
use warnings;

use Carp qw(croak);
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

eq_or_diff(
    Locale::PO::Utils->expand_gettext(
        'foo {plus} bar {plus} baz = {num} items',
        plus => q{+},
        num  => 3,
    ),
    'foo + bar + baz = 3 items',
    'class method',
);

eq_or_diff(
    $obj->expand_gettext(
        'foo {plus} bar {plus} baz = {num} items',
        plus => q{+},
        num  => 3,
    ),
    'foo + bar + baz = 3 items',
    'object method',
);
