#!perl -T

use strict;
use warnings;

use Carp qw(croak);
use Test::More tests => 74 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

is_deeply(
    [ $obj->expand_maketext() ],
    [ undef ],
    'undef',
);

my @data = (
    [
        undef,
        'foo [_1] bar [quant,_2,singular] baz',
        'foo and bar 0 singular baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 singular baz',
    ],
    [
        undef,
        'foo [_1] bar [*,_2,singular] baz',
        'foo and bar 0 singular baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 singular baz',
    ],
    [
        undef,
        'foo [_1] bar [quant,_2,singular,plural] baz',
        'foo and bar 0 plural baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        undef,
        'foo [_1] bar [*,_2,singular,plural] baz',
        'foo and bar 0 plural baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        undef,
        'foo [_1] bar [quant,_2,singular,plural,zero] baz',
        'foo and bar zero baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        undef,
        'foo [_1] bar [*,_2,singular,plural,zero] baz',
        'foo and bar zero baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        1,
        'foo %1 bar %quant(%2,singular) baz',
        'foo and bar 0 singular baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 singular baz',
    ],
    [
        1,
        'foo %1 bar %*(%2,singular) baz',
        'foo and bar 0 singular baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 singular baz',
    ],
    [
        1,
        'foo %1 bar %quant(%2,singular,plural) baz',
        'foo and bar 0 plural baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        1,
        'foo %1 bar %*(%2,singular,plural) baz',
        'foo and bar 0 plural baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        1,
        'foo %1 bar %quant(%2,singular,plural,zero) baz',
        'foo and bar zero baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
    [
        1,
        'foo %1 bar %*(%2,singular,plural,zero) baz',
        'foo and bar zero baz',
        'foo and bar 1 singular baz',
        'foo and bar 2 plural baz',
    ],
);

for my $data (@data) {
    for my $number (0 .. 2) {
        eq_or_diff(
            Locale::PO::Utils->expand_maketext(
                @{$data}[0, 1],
                'and',
                $number,
            ),
            $data->[$number + 2],
            'class method, '
            . ( $data->[0] ? 'gettext' : 'maketext' )
            . " style, $number",
        );
        eq_or_diff(
            $obj->expand_maketext(
                @{$data}[0, 1],
                'and',
                $number,
            ),
            $data->[$number + 2],
            'object method, '
            . ( $data->[0] ? 'gettext' : 'maketext' )
            . " style, '$data->[1]', 'and', $number",
        );
    }
}