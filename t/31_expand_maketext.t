#!perl -T

use strict;
use warnings;

use Test::More tests => 38 + 1;
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
    {
        style  => 'maketext',
        text   => 'foo [_1] bar [quant,_2,singular] baz',
        result => [
            'foo and bar 0 singular baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 singular baz',
        ],
    },
    {
        text   => 'foo [_1] bar [*,_2,singular] baz',
        result => [
            'foo and bar 0 singular baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 singular baz',
        ],
    },
    {
        style  => 'gettext',
        text   => 'foo %1 bar %quant(%2,singular) baz',
        result => [
            'foo and bar 0 singular baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 singular baz',
        ],
    },
    {
        text   => 'foo %1 bar %*(%2,singular) baz',
        result => [
            'foo and bar 0 singular baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 singular baz',
        ],
    },
    {
        style  => 'maketext',
        text   => 'foo [_1] bar [quant,_2,singular,plural] baz',
        result => [
            'foo and bar 0 plural baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        text   => 'foo [_1] bar [*,_2,singular,plural] baz',
        result => [
            'foo and bar 0 plural baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        style  => 'gettext',
        text   => 'foo %1 bar %quant(%2,singular,plural) baz',
        result => [
            'foo and bar 0 plural baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        text   => 'foo %1 bar %*(%2,singular,plural) baz',
        result => [
            'foo and bar 0 plural baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        style  => 'maketext',
        text   => 'foo [_1] bar [quant,_2,singular,plural,zero] baz',
        result => [
            'foo and bar zero baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        text   => 'foo [_1] bar [*,_2,singular,plural,zero] baz',
        result => [
            'foo and bar zero baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        style  => 'gettext',
        text   => 'foo %1 bar %quant(%2,singular,plural,zero) baz',
        result => [
            'foo and bar zero baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
    {
        text   => 'foo %1 bar %*(%2,singular,plural,zero) baz',
        result => [
            'foo and bar zero baz',
            'foo and bar 1 singular baz',
            'foo and bar 2 plural baz',
        ],
    },
);

for my $data (@data) {
    for my $number (0 .. 2) {
        if ( exists $data->{style} ) {
            $obj->set_is_gettext_style( $data->{style} eq 'gettext' );
        }
        eq_or_diff(
            $obj->expand_maketext(
                $data->{text},
                'and',
                $number,
            ),
            $data->{result}->[$number],
            ( $obj->is_gettext_style() ? 'gettext' : 'maketext' )
            . " style, '$data->{text}', 'and', $number",
        );
    }
}
