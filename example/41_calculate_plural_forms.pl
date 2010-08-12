#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

# initialize English plural forms
my $obj = Locale::PO::Utils->new(
    plural_forms => 'nplurals=2; plural=(n != 1)',
);

printf
    "English:\nplural_froms = '%s'\nnplurals = %s\n\n",
    $obj->get_plural_forms(),
    $obj->get_nplurals();

my $plural_code = $obj->get_plural_code();
for (0 .. 2) {
    printf
        "The EN plural from from %d is %d\n",
        $_,
        $plural_code->($_),
}

# change to Russian plurla forms
$obj->set_plural_forms(
    'nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 or n%100>=20) ? 1 : 2)'
);

printf
    "Russian:\nplural_froms = '%s'\nnplurals = %s\n\n",
    $obj->get_plural_forms(),
    $obj->get_nplurals();

$plural_code = $obj->get_plural_code();
for (0 .. 2, 5, 100 .. 102, 105, 110 .. 112, 115, 120 .. 122, 125) { ## no critic (MagicNumbers)
    printf
        "The RU plural from from %d is %d\n",
        $_,
        $plural_code->($_),
}

# $Id: 41_calculate_plural_forms.pl 534 2010-08-12 05:31:29Z steffenw $

__END__

Output:

English:
plural_froms = 'nplurals=2; plural=(n != 1)'
nplurals = 2

The EN plural from from 0 is 1
The EN plural from from 1 is 0
The EN plural from from 2 is 1
Russian:
plural_froms = 'nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 or n%100>=20) ? 1 : 2)'
nplurals = 3

The RU plural from from 0 is 2
The RU plural from from 1 is 0
The RU plural from from 2 is 1
The RU plural from from 5 is 2
The RU plural from from 100 is 2
The RU plural from from 101 is 0
The RU plural from from 102 is 1
The RU plural from from 105 is 2
The RU plural from from 110 is 2
The RU plural from from 111 is 2
The RU plural from from 112 is 2
The RU plural from from 115 is 2
The RU plural from from 120 is 2
The RU plural from from 121 is 0
The RU plural from from 122 is 1
The RU plural from from 125 is 2