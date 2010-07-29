#!perl -T

use strict;
use warnings;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Differences;
BEGIN {
    use_ok('Locale::PO::Utils');
}

my $obj = Locale::PO::Utils->new();

my $msgstr = <<'EOT';
Project-Id-Version: Testproject
Report-Msgid-Bugs-To: <bug@example.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
X-Poedit-Language: German
X-Poedit-Country: GERMANY
X-Poedit-SourceCharset: utf-8
EOT

# read keys
eq_or_diff(
    $obj->get_header_msgstr_data($msgstr, 'Project-Id-Version'),
    'Testproject',
    'get 1 item of header msgstr',
);
eq_or_diff(
    $obj->get_header_msgstr_data(
        $msgstr,
        [qw(Project-Id-Version Report-Msgid-Bugs-To-Mail extended)],
    ),
    [
        'Testproject',
        'bug@example.org',
        [
            'X-Poedit-Language',
            'German',
            'X-Poedit-Country',
            'GERMANY',
            'X-Poedit-SourceCharset',
            'utf-8',
        ],
    ],
    'get 2 items of header msgstr',
);
