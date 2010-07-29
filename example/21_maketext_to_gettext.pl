#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

my $obj = Locale::PO::Utils->new();

() = print
    "Single mode (get 1 item as scalar):\n",
    $obj->maketext_to_gettext('foo [_1] bar [quant,_2,singluar,plural,zero] baz');

my @array = $obj->maketext_to_gettext(
    'foo [_1] bar',
    'bar [*,_2,singluar,plural] baz'
);
() = print
    "Multiple mode (get 0 or many items as array):\n",
    $array[0],
    "\n",
    $array[1],
    "\n";

# $Id: 21_maketext_to_gettext.pl 513 2010-07-29 15:16:57Z steffenw $

__END__

Output:

Single mode (get 1 item as scalar):
foo %1 bar %quant(%2,singluar,plural,zero) bazMultiple mode (get 0 or many items as array):
foo %1 bar
bar %*(%2,singluar,plural) baz

