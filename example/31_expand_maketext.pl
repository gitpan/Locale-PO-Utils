#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

# code to format numeric values
my $numeric_code = sub {
    my $value = shift;

    defined $value
        or return $value;
    # set the , between 3 digits
    while ( $value =~ s{(\d+) (\d{3})}{$1,$2}xms ) {}
    # German nmber format
    $value =~ tr{.,}{,.};

    return $value;
};

my $obj = Locale::PO::Utils->new(
    numeric_code => $numeric_code,
);

for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_maketext(
            'foo [_1] bar [quant,_2,singular,plural,zero] baz',
            'and',
            $_,
        ),
        "\n";
}
$obj->clear_numeric_code();
for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
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
for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_maketext(
            'foo %1 bar %quant(%2,singular,plural,zero) baz',
            'and',
            $_,
        ),
        "\n";
}
$obj->set_numeric_code($numeric_code);
for (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        $obj->expand_maketext(
            'foo %1 bar %*(%2,singular,plural,zero) baz',
            'and',
            $_,
        ),
        "\n";
}

# $Id: 31_expand_maketext.pl 540 2010-08-13 21:17:39Z steffenw $

__END__

Output:

foo and bar [quant,_2,singular,plural,zero] baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar 3.234.567,890 plural baz
foo and bar 4.234.567,89 plural baz
foo and bar [*,_2,singular,plural,zero] baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar 3234567.890 plural baz
foo and bar 4234567.89 plural baz
foo and bar %quant(%2,singular,plural,zero) baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar 3234567.890 plural baz
foo and bar 4234567.89 plural baz
foo and bar %*(%2,singular,plural,zero) baz
foo and bar zero baz
foo and bar 1 singular baz
foo and bar 2 plural baz
foo and bar 3.234.567,890 plural baz
foo and bar 4.234.567,89 plural baz
