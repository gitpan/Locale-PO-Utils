#!perl -T

use strict;
use warnings;

use Test::More tests => 50 + 1;
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
        text   => '(1) foo [_1] bar [quant,_2,singular] baz [_3]',
        result => [
            '(1) foo and bar [quant,_2,singular] baz [_3]',
            '(1) foo and bar 0 singular baz [_3]',
            '(1) foo and bar 1 singular baz [_3]',
            '(1) foo and bar 2 singular baz [_3]',
        ],
    },
    {
        text   => '(2) foo [_1] bar [*,_2,singular] baz [_3]',
        result => [
            '(2) foo and bar [*,_2,singular] baz [_3]',
            '(2) foo and bar 0 singular baz [_3]',
            '(2) foo and bar 1 singular baz [_3]',
            '(2) foo and bar 2 singular baz [_3]',
        ],
    },
    {
        style  => 'gettext',
        text   => '(3) foo %1 bar %quant(%2,singular) baz %3',
        result => [
            '(3) foo and bar %quant(%2,singular) baz %3',
            '(3) foo and bar 0 singular baz %3',
            '(3) foo and bar 1 singular baz %3',
            '(3) foo and bar 2 singular baz %3',
        ],
    },
    {
        text   => '(4) foo %1 bar %*(%2,singular) baz %3',
        result => [
            '(4) foo and bar %*(%2,singular) baz %3',
            '(4) foo and bar 0 singular baz %3',
            '(4) foo and bar 1 singular baz %3',
            '(4) foo and bar 2 singular baz %3',
        ],
    },
    {
        style  => 'maketext',
        text   => '(5) foo [_1] bar [quant,_2,singular,plural] baz [_3]',
        result => [
            '(5) foo and bar [quant,_2,singular,plural] baz [_3]',
            '(5) foo and bar 0 plural baz [_3]',
            '(5) foo and bar 1 singular baz [_3]',
            '(5) foo and bar 2 plural baz [_3]',
        ],
    },
    {
        text   => '(6) foo [_1] bar [*,_2,singular,plural] baz [_3]',
        result => [
            '(6) foo and bar [*,_2,singular,plural] baz [_3]',
            '(6) foo and bar 0 plural baz [_3]',
            '(6) foo and bar 1 singular baz [_3]',
            '(6) foo and bar 2 plural baz [_3]',
        ],
    },
    {
        style  => 'gettext',
        text   => '(7) foo %1 bar %quant(%2,singular,plural) baz %3',
        result => [
            '(7) foo and bar %quant(%2,singular,plural) baz %3',
            '(7) foo and bar 0 plural baz %3',
            '(7) foo and bar 1 singular baz %3',
            '(7) foo and bar 2 plural baz %3',
        ],
    },
    {
        text   => '(8) foo %1 bar %*(%2,singular,plural) baz %3',
        result => [
            '(8) foo and bar %*(%2,singular,plural) baz %3',
            '(8) foo and bar 0 plural baz %3',
            '(8) foo and bar 1 singular baz %3',
            '(8) foo and bar 2 plural baz %3',
        ],
    },
    {
        style  => 'maketext',
        text   => '(9) foo [_1] bar [quant,_2,singular,plural,zero] baz [_3]',
        result => [
            '(9) foo and bar [quant,_2,singular,plural,zero] baz [_3]',
            '(9) foo and bar zero baz [_3]',
            '(9) foo and bar 1 singular baz [_3]',
            '(9) foo and bar 2 plural baz [_3]',
        ],
    },
    {
        text   => '(10) foo [_1] bar [*,_2,singular,plural,zero] baz [_3]',
        result => [
            '(10) foo and bar [*,_2,singular,plural,zero] baz [_3]',
            '(10) foo and bar zero baz [_3]',
            '(10) foo and bar 1 singular baz [_3]',
            '(10) foo and bar 2 plural baz [_3]',
        ],
    },
    {
        style  => 'gettext',
        text   => '(11) foo %1 bar %quant(%2,singular,plural,zero) baz %3',
        result => [
            '(11) foo and bar %quant(%2,singular,plural,zero) baz %3',
            '(11) foo and bar zero baz %3',
            '(11) foo and bar 1 singular baz %3',
            '(11) foo and bar 2 plural baz %3',
        ],
    },
    {
        text   => '(12) foo %1 bar %*(%2,singular,plural,zero) baz %3',
        result => [
            '(12) foo and bar %*(%2,singular,plural,zero) baz %3',
            '(12) foo and bar zero baz %3',
            '(12) foo and bar 1 singular baz %3',
            '(12) foo and bar 2 plural baz %3',
        ],
    },
);

for my $data (@data) {
    my $index = 0;
    for my $number (undef, 0 .. 2) {
        my $defined_number
            = defined $number
            ? $number
            : 'undef';
        if ( exists $data->{style} ) {
            $obj->set_is_gettext_style( $data->{style} eq 'gettext' );
        }
        eq_or_diff(
            $obj->expand_maketext(
                $data->{text},
                'and',
                $number,
            ),
            $data->{result}->[$index++],
            ( $obj->is_gettext_style() ? 'gettext' : 'maketext' )
            . " style, '$data->{text}', 'and', $defined_number",
        );
    }
}
