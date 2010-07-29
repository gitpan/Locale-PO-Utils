#!perl -T

use strict;
use warnings;

use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

eq_or_diff(
    $obj->maketext_to_gettext('foo [_1] bar [quant,_2,singluar,plural,zero] baz'),
    'foo %1 bar %quant(%2,singluar,plural,zero) baz',
    'single mode',
);

eq_or_diff(
    [ $obj->maketext_to_gettext() ],
    [],
    'empty multiple mode',
);

is_deeply(
    [ $obj->maketext_to_gettext(undef) ],
    [ undef ],
    'undef inside',
);

eq_or_diff(
    [
        $obj->maketext_to_gettext(
            'foo [_1] bar',
            'bar [*,_2,singluar,plural] baz'
        )
    ],
    [
        'foo %1 bar',
        'bar %*(%2,singluar,plural) baz',
    ],
    'multiple mode',
);
