#!perl -T

use strict;
use warnings;

use Test::More tests => 6 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

# read keys
eq_or_diff(
    [ sort @{ $obj->get_all_header_keys() } ],
    [ qw(
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
    ) ],
    'get_all_header_keys',
);

eq_or_diff(
    $obj->build_header_msgstr() . "\n",
    << 'EOT',
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
EOT
    'empty build_header_msgstr',
);

eq_or_diff(
    $obj->build_header_msgstr(undef) . "\n",
    << 'EOT',
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
EOT
    'undef build_header_msgstr',
);

eq_or_diff(
    $obj->build_header_msgstr([
        undef,
        [undef, 'bug@example.org'],
        undef,
        undef,
        [],
        [],
        undef,
        'text/bla',
    ]) . "\n",
    << 'EOT',
Report-Msgid-Bugs-To: <bug@example.org>
MIME-Version: 1.0
Content-Type: text/bla; charset=UTF-8
Content-Transfer-Encoding: 8bit
EOT
    'arrayref build_header_msgstr',
);

eq_or_diff(
    $obj->build_header_msgstr({
        'Project-Id-Version'        => 'Testproject',
        'Report-Msgid-Bugs-To-Name' => 'Bug Reporter',
        'Report-Msgid-Bugs-To-Mail' => 'bug@example.org',
        'POT-Creation-Date'         => 'no POT creation date',
        'PO-Revision-Date'          => 'no PO revision date',
        'Last-Translator-Name'      => 'Steffen Winkler',
        'Last-Translator-Mail'      => 'steffenw@example.org',
        'Language-Team-Name'        => 'MyTeam',
        'Language-Team-Mail'        => 'cpan@example.org',
        'MIME-Version'              => '1.0',
        'Content-Type'              => 'text/plain',
        'charset'                   => 'utf-8',
        'Content-Transfer-Encoding' => '8bit',
        'extended'                  => [
            'X-Poedit-Language'      => 'German',
            'X-Poedit-Country'       => 'GERMANY',
            'X-Poedit-SourceCharset' => 'utf-8',
        ],
    }) . "\n",
    << 'EOT',
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
    'hashref build_header_msgstr',
);
