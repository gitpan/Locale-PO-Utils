#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

# method expand_gettext as class method

() = print
    Locale::PO::Utils->expand_gettext(
        'CLASS: foo {plus} bar {plus} baz = {num} items',
        plus => q{+},
        num  => 3,
    ),
    "\n";

# method expand_gettext as object method

() = print
    Locale::PO::Utils->new()->expand_gettext(
        'OBJECT: foo {plus} bar {plus} baz = {num} items',
        plus => q{+},
        num  => 3,
    ),
    "\n";

# $Id: 32_expand_gettext.pl 512 2010-07-29 12:15:48Z steffenw $

__END__

Output:

CLASS: foo + bar + baz = 3 items
OBJECT: foo + bar + baz = 3 items

