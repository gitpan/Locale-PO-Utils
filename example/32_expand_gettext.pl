#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

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

for my $value (undef, 0 .. 2, '3234567.890', 4_234_567.890) { ## no critic (MagicNumbers)
    () = print
        Locale::PO::Utils->new()->expand_gettext(
            'foo {plus} bar {plus} baz = {num} items',
            plus => q{+},
            num  => $value,
    ),
    "\n";
}

# $Id: 32_expand_gettext.pl 540 2010-08-13 21:17:39Z steffenw $

__END__

Output:

foo + bar + baz = {num} items
foo + bar + baz = 0 items
foo + bar + baz = 1 items
foo + bar + baz = 2 items
foo + bar + baz = 3234567.890 items
foo + bar + baz = 4234567.89 items
