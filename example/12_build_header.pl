#!perl -T

use strict;
use warnings;

our $VERSION = 0;

require Locale::PO::Utils;

my $obj = Locale::PO::Utils->new();

# get all header keys
() = print
    "all header keys:\n",
    (
        join
            "\n",
            sort @{ $obj->get_all_header_keys() }
    ),
    "\n\n";

# build an empty header msgstr
() = print
    "empty header msgstr:\n",
    $obj->build_header_msgstr(),
    "\n\n";


# build a customized header msgstr
() = print
    "all header keys:\n",
    $obj->build_header_msgstr({
        'Project-Id-Version'        => 'Testproject',
        'Report-Msgid-Bugs-To-Name' => 'Bug Reporter',
        'Report-Msgid-Bugs-To-Mail' => 'bug@example.org', ## no critic (InterpolationOfMetachars)
        'POT-Creation-Date'         => 'no POT creation date',
        'PO-Revision-Date'          => 'no PO revision date',
        'Last-Translator-Name'      => 'Steffen Winkler',
        'Last-Translator-Mail'      => 'steffenw@example.org', ## no critic (InterpolationOfMetachars)
        'Language-Team-Name'        => 'MyTeam',
        'Language-Team-Mail'        => 'cpan@example.org', ## no critic (InterpolationOfMetachars)
        'MIME-Version'              => '1.0',
        'Content-Type'              => 'text/plain',
        'charset'                   => 'utf-8',
        'Content-Transfer-Encoding' => '8bit',
        'extended'                  => [
            'X-Poedit-Language'      => 'German',
            'X-Poedit-Country'       => 'GERMANY',
            'X-Poedit-SourceCharset' => 'utf-8',
        ],
    }),
    "\n";

# $Id: 12_build_header.pl 513 2010-07-29 15:16:57Z steffenw $

__END__

Output:

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
