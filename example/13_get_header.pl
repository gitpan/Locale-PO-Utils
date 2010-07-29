#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Data::Dumper;
require Locale::PO::Utils;

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

() = print
    "get 1 item of header msgstr as scalar:\n",
    $obj->get_header_msgstr_data($msgstr, 'Project-Id-Version'),
    "\n";

my $array_ref = $obj->get_header_msgstr_data(
    $msgstr,
    [qw(Project-Id-Version Report-Msgid-Bugs-To-Mail extended)],
);
() = print
    "get 0 or many items of header msgstr as array reference:\n",
    Data::Dumper->new([$array_ref], ['array_ref'])->Indent(1)->Dump();

# $Id: 13_get_header.pl 513 2010-07-29 15:16:57Z steffenw $

__END__

Output:

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

