#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Cwd qw(getcwd chdir);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 6);

my @data = (
    {
        test   => '12_build_header',
        path   => 'example',
        script => '-I../lib -T 12_build_header.pl',
        result => <<'EOT',
all header keys:
Content-Transfer-Encoding
Content-Type
Language-Team-Mail
Language-Team-Name
Last-Translator-Mail
Last-Translator-Name
MIME-Version
PO-Revision-Date
POT-Creation-Date
Plural-Forms
Project-Id-Version
Report-Msgid-Bugs-To-Mail
Report-Msgid-Bugs-To-Name
charset
extended

empty header msgstr:
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

all header keys:
Project-Id-Version: Testproject
Report-Msgid-Bugs-To: Bug Reporter <bug@example.org>
POT-Creation-Date: no POT creation date
PO-Revision-Date: no PO revision date
Last-Translator: Steffen Winkler <steffenw@example.org>
Language-Team: MyTeam <cpan@example.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Poedit-Language: German
X-Poedit-Country: GERMANY
X-Poedit-SourceCharset: utf-8
EOT
    },
    {
        test   => '13_get_header',
        path   => 'example',
        script => '-I../lib -T 13_get_header.pl',
        result => <<'EOT',
get 1 item of header msgstr as scalar:
Testproject
get 0 or many items of header msgstr as array reference:
$array_ref = [
  'Testproject',
  'bug@example.org',
  [
    'X-Poedit-Language',
    'German',
    'X-Poedit-Country',
    'GERMANY',
    'X-Poedit-SourceCharset',
    'utf-8'
  ]
];
EOT
    },
    {
        test   => '21_maketext_to_gettext',
        path   => 'example',
        script => '-I../lib -T 21_maketext_to_gettext.pl',
        result => <<'EOT',
Single mode (get 1 item as scalar):
foo %1 bar %quant(%2,singluar,plural,zero) bazMultiple mode (get 0 or many items as array):
foo %1 bar
bar %*(%2,singluar,plural) baz
EOT
    },
    {
        test   => '31_expand_maketext',
        path   => 'example',
        script => '-I../lib -T 31_expand_maketext.pl',
        result => <<'EOT',
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
EOT
    },
    {
        test   => '32_expand_gettext',
        path   => 'example',
        script => '-I../lib -T 32_expand_gettext.pl',
        result => <<'EOT',
CLASS: foo + bar + baz = 3 items
OBJECT: foo + bar + baz = 3 items
EOT
    },
    {
        test   => '41_calculate_plural_forms',
        path   => 'example',
        script => '-I../lib -T 41_calculate_plural_forms.pl',
        result => <<'EOT',
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
EOT
    },
);

for my $data (@data) {
    my $dir = getcwd();
    chdir("$dir/$data->{path}");
    my $result = qx{perl $data->{script} 2>&3};
    chdir($dir);
    eq_or_diff(
        $result,
        $data->{result},
        $data->{test},
    );
}

