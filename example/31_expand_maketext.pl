#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

my $obj = Locale::PO::Utils->new();

for (0 .. 2) {
    () = print
        $obj->expand_maketext(
            'foo [_1] bar [quant,_2,singular,plural,zero] baz',
            'and',
            $_,
        ),
        "\n";
}
for (0 .. 2) {
    () = print
        $obj->expand_maketext(
            'foo [_1] bar [*,_2,singular,plural,zero] baz',
            'and',
            $_,
        ),
        "\n";
}

# true is gettext style
# false is maketext style
$obj->set_is_gettext_style(1);
for (0 .. 2) {
    () = print
        $obj->expand_maketext(
            'foo %1 bar %quant(%2,singular,plural,zero) baz',
            'and',
            $_,
        ),
        "\n";
}
for (0 .. 2) {
    () = print
        $obj->expand_maketext(
            'foo %1 bar %*(%2,singular,plural,zero) baz',
            'and',
            $_,
        ),
        "\n";
}

# $Id: 31_expand_maketext.pl 512 2010-07-29 12:15:48Z steffenw $

__END__

Output:

foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz

