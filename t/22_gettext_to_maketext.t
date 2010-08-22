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
    $obj->gettext_to_maketext('foo %1 bar %quant(%2,singluar,plural,zero) baz %#(%3)'),
    'foo [_1] bar [quant,_2,singluar,plural,zero] baz [#,_3]',
    'single mode',
);

eq_or_diff(
    [ $obj->gettext_to_maketext() ],
    [],
    'empty multiple mode',
);

is_deeply(
    [ $obj->gettext_to_maketext(undef) ],
    [ undef ],
    'undef inside',
);

eq_or_diff(
    [
        $obj->gettext_to_maketext(
            'foo %1 bar',
            'bar %*(%2,singluar,plural) baz',
            'baz %#(%3)',
        )
    ],
    [
        'foo [_1] bar',
        'bar [*,_2,singluar,plural] baz',
        'baz [#,_3]',
    ],
    'multiple mode',
);