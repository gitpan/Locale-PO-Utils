package Locale::PO::Utils;

use Moose;
use MooseX::StrictConstructor;
use MooseX::FollowPBP;
use English qw(-no_match_vars $EVAL_ERROR);
use Carp qw(confess);
use Clone qw(clone);
use Params::Validate qw(:all);
require Safe;

our $VERSION = '0.05';

# read/write header

my (@HEADER_KEYS, @HEADER_FORMATS, @HEADER_DEFAULTS, @HEADER_REGEX);
{
    my @header = (
        [ project_id_version        => 'Project-Id-Version: %s'        ],
        [ report_msgid_bugs_to      => 'Report-Msgid-Bugs-To: %s <%s>' ],
        [ pot_creation_date         => 'POT-Creation-Date: %s'         ],
        [ po_revision_date          => 'PO-Revision-Date: %s'          ],
        [ last_translator           => 'Last-Translator: %s <%s>'      ],
        [ language_team             => 'Language-Team: %s <%s>'        ],
        [ mime_version              => 'MIME-Version: %s'              ],
        [ content_type              => 'Content-Type: %s; charset=%s'  ],
        [ content_transfer_encoding => 'Content-Transfer-Encoding: %s' ],
        [ plural_forms              => 'Plural-Forms: %s'              ],
        [ extended                  => '%s: %s'                        ],
    );
    @HEADER_KEYS     = map {$_->[0]} @header;
    @HEADER_FORMATS  = map {$_->[1]} @header;
    @HEADER_DEFAULTS = (
        undef,
        undef,
        undef,
        undef,
        undef,
        undef,
       '1.0',
        ['text/plain', undef],
        '8bit',
        undef,
        undef,
    );
    @HEADER_REGEX = (
        qr{\A \QProject-Id-Version:\E        \s* (.*) \s* \z}xmsi,
        [
            qr{\A \QReport-Msgid-Bugs-To:\E  \s* ([^<]*) \s+ < ([^>]*) > \s* \z}xmsi,
            qr{\A \QReport-Msgid-Bugs-To:\E  \s* (.*) () \s* \z}xmsi,
        ],
        qr{\A \QPOT-Creation-Date:\E         \s* (.*) \s* \z}xmsi,
        qr{\A \QPO-Revision-Date:\E          \s* (.*) \s* \z}xmsi,
        [
            qr{\A \QLast-Translator:\E       \s* ([^<]*) \s+ < ([^>]*) > \s* \z}xmsi,
            qr{\A \QLast-Translator:\E       \s* (.*) () \s* \z}xmsi,
        ],
        [
            qr{\A \QLanguage-Team:\E         \s* ([^<]*) \s+ < ([^>]*) > \s* \z}xmsi,
            qr{\A \QLanguage-Team:\E         \s* (.*) () \s* \z}xmsi,
        ],
        qr{\A \QMIME-Version:\E              \s* (.*) \s* \z}xmsi,
        qr{\A \QContent-Type:\E              \s* ([^;]*); \s* charset=(\S*) \s* \z}xmsi,
        qr{\A \QContent-Transfer-Encoding:\E \s* (.*) \s* \z}xmsi,
        qr{\A \QPlural-Forms:\E              \s* (.*) \s* \z}xmsi,
        qr{\A ([^:]*) :                      \s* (.*) \s* \z}xms,
    );
}

## no critic (MagicNumbers)
my %hash2array = (
    'Project-Id-Version'        => 0,
    'Report-Msgid-Bugs-To-Name' => [1, 0],
    'Report-Msgid-Bugs-To-Mail' => [1, 1],
    'POT-Creation-Date'         => 2,
    'PO-Revision-Date'          => 3,
    'Last-Translator-Name'      => [4, 0],
    'Last-Translator-Mail'      => [4, 1],
    'Language-Team-Name'        => [5, 0],
    'Language-Team-Mail'        => [5, 1],
    'MIME-Version'              => 6,
    'Content-Type'              => [7, 0],
    'charset'                   => [7, 1],
    'Content-Transfer-Encoding' => 8,
    'Plural-Forms'              => 9,
);
my $index_extended = 10;
## use critic (MagicNumbers)

has charset => (
    is      => 'rw',
    isa     => 'Str',
    default => 'UTF-8',
);
has eol => (
    is      => 'rw',
    isa     => 'Str',
    default => "\n",
);
has separator => (
    is      => 'rw',
    isa     => 'Str',
    default => "\n",
);

has is_gettext_style => (
    is     => 'rw',
    isa    => 'Bool',
    writer => 'set_is_gettext_style',
    reader => 'is_gettext_style',
);

has plural_forms => (
    is      => 'rw',
    isa     => 'Str',
    default => 'nplurals=1; plural=0',
);
has nplurals => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);
has plural_code => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub { return sub { return 0 } },
);

my $valid_keys_regex
    = '(?xsm-i:\A (?: '
    . join(
        q{|},
        map {
            quotemeta $_
        } 'extended', keys %hash2array
    )
    . ' ) \z)';

sub get_all_header_keys {
    return ['extended', keys %hash2array];
}

sub _hash2array {
    my ($self, $hash_data) = @_;
    validate_with(
        params => $hash_data,
        spec   => {
            (
                map {
                    ($_ => {type => SCALAR, optional => 1});
                } keys %hash2array
            ),
            extended => {type => ARRAYREF, optional => 1},
        },
    );

    my $array_data = clone(\@HEADER_DEFAULTS);
    my $charset = $self->get_charset();
    $array_data->[ $hash2array{charset}->[0] ]->[ $hash2array{charset}->[1] ]
        = $charset;
    KEY:
    for my $key (keys %{$hash_data}) {
        if ($key eq 'extended') {
            $array_data->[$index_extended] = $hash_data->{extended};
            next KEY;
        }
        if (ref $hash2array{$key} eq 'ARRAY') {
            $array_data->[ $hash2array{$key}->[0] ]->[ $hash2array{$key}->[1] ]
                = $hash_data->{$key};
            next KEY;
        }
        $array_data->[ $hash2array{$key} ] = $hash_data->{$key};
    }

    return $array_data;
};

sub build_header_msgstr { ## no critic (ArgUnpacking
    my ($self, $anything) = validate_pos(
        @_,
        {isa => __PACKAGE__},
        {
            type     => HASHREF | ARRAYREF | UNDEF,
            optional => 1,
        },
    );

    my $array_data
        = ref $anything eq 'HASH'
        ? $self->_hash2array($anything)
        : $anything;
    my @header;
    HEADER_KEY:
    for my $index (0 .. $#HEADER_KEYS) {
        my $data
            = $array_data->[$index]
            || $HEADER_DEFAULTS[$index];
        defined $data
            or next HEADER_KEY;
        my $key    = $HEADER_KEYS[$index];
        my $format = $HEADER_FORMATS[$index];
        my @data
            = ref $data eq 'ARRAY'
            ? @{ $data }
            : $data;
        if ($key eq 'content_type') {
            $data[1] ||= $self->get_charset();
        }
        @data
            or next HEADER_KEY;
        if ($key eq 'extended') {
            @data % 2
               and confess "$key pairs are not pairwise";
            while (my ($name, $value) = splice @data, 0, 2) {
                push @header, sprintf $format, $name, $value;
            }
        }
        else {
            my $row = sprintf $format, map {defined $_ ? $_ : q{}} @data;
            $row =~ s{\s* <> \z}{}xms; # delete an empty mail address
            $row =~ s{\s+}{ }xmsg;     # delete space before a mail address
            push @header, $row;
        }
    }

    return join "\n", @header;
}

sub split_header_msgstr { ## no critic (ArgUnpacking)
    my ($self, $msgstr) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => SCALAR},
    );

    my @cols;
    my $separator = $self->get_separator();
    my @lines = split m{\Q$separator\E}xms, $msgstr;
    LINE:
    while (1) {
        my $line = shift @lines;
        defined $line
           or last LINE;
        # run the regex for the selected column
        for my $index (0 .. $#HEADER_REGEX) {
            my $header_regex = $HEADER_REGEX[$index];
            my @result;
            # more regexes are necessary
            if (ref $header_regex eq 'ARRAY') {
                # run from special to more common regex
                INNER_REGEX:
                for my $inner_regex ( @{$header_regex} ) {
                    @result = $line =~ $inner_regex;
                    last INNER_REGEX if @result;
                }
            }
            # only 1 regex is necessary
            else {
                @result = $line =~ $header_regex;
            }
            # save the result to the selected column
            if (@result) {
                # column extended is multiline
                defined $cols[$index]
                ? (
                    ref $cols[$index] eq 'ARRAY'
                    ? ( push @{ $cols[$index] }, @result )
                    : ( $cols[$index] = [ $cols[$index], @result ] )
                )
                : ( $cols[$index] = @result > 1 ? \@result : $result[0] );
                next LINE;
            }
        }
    }

    return \@cols;
}

sub get_header_msgstr_data { ## no critic (ArgUnpacking)
    my ($self, $anything, $key) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => ARRAYREF | SCALAR},
        {
            type      => SCALAR | ARRAYREF,
            callbacks => {
                check_keys => sub {
                    my $check_key = shift;
                    if (ref $check_key eq 'ARRAY') {
                        return 1;
                    }
                    else {
                        return $check_key =~ $valid_keys_regex;
                    }
                },
            },
        },
    );

    my $array_ref
        = (ref $anything eq 'ARRAY')
        ? $anything
        : $self->split_header_msgstr($anything);

    if (ref $key eq 'ARRAY') {
        return [
            map {
                $self->get_header_msgstr_data($array_ref, $_);
            } @{$key}
        ];
    }

    my $index
        = $key eq 'extended'
        ? $index_extended
        : $hash2array{$key};
    if (ref $index eq 'ARRAY') {
        return $array_ref->[ $index->[0] ]->[ $index->[1] ];
    }

    return $array_ref->[$index];
}

# calculate plural forms

sub calculate_plural_forms {
    my $self = shift;

    my $plural_forms = $self->get_plural_forms();
    $plural_forms =~ s{\b ( nplurals | plural | n ) \b}{\$$1}xmsg;
    my $safe = Safe->new();
    {
        my $code = <<"EOC";
            my \$n = 0;
            my (\$nplurals, \$plural);
            $plural_forms;
            \$nplurals;
EOC
        $self->set_nplurals(
            $safe->reval($code)
                or confess "Code of Plural-Forms $plural_forms is not safe, $EVAL_ERROR"
        );
    }
    {
        my $code = <<"EOC";
            sub {
                my \$n = shift;

                my (\$nplurals, \$plural);
                $plural_forms;

                return \$plural || 0;
            }
EOC
        $self->set_plural_code(
            $safe->reval($code)
                or confess "Code $plural_forms is not safe, $EVAL_ERROR"
        );
    }

    return $self;
}

# different writing of placeholders

my $maketext_to_gettext_scalar = sub {
    my $string = shift;

    defined $string
        or return $string;
    $string =~ s{
        \[ \s*
        (?:
            ( [A-Za-z*\#] [A-Za-z_]* ) # $1 - function call
            \s* , \s*
            _ ( [1-9]\d* )             # $2 - variable
            ( [^\]]* )                 # $3 - arguments
            |                          # or
            _ ( [1-9]\d* )             # $4 - variable
        )
        \s* \]
    }
    {
        $4 ? "%$4" : "%$1(%$2$3)"
    }xmsge;

    return $string;
};

sub maketext_to_gettext {
    my (undef, @strings) = @_;

    return
        @strings > 1
        ? map { $maketext_to_gettext_scalar->($_) } @strings
        : @strings
        ? $maketext_to_gettext_scalar->( $strings[0] )
        : ();
}

# expand placeholders

sub expand_maketext {
    my ($self, $text, @args) = @_;

    defined $text
        or return $text;

    my $replace = sub {
        if (defined $6) { # replace only
            my $index = $6 - 1;
            exists $args[$index]
                or return $1;
            my $value = $args[$index];
            return defined $value ? $value : q{};
        }
        if (defined $2) { # quant
            my $index = $2 - 1;
            exists $args[$index]
                or return $1;
            my $value    = $args[$index];
            my $singular = $3;
            my $plural   = $4;
            my $zero     = $5;
            $value = defined $value ? $value : q{};
            no warnings qw(uninitialized numeric); ## no critic (NoWarnings)
            return
                +( defined $zero && $value == 0 )
                ? $zero
                : ( defined $plural && $value == 1 )
                ? (
                    defined $singular
                    ? "$value $singular"
                    : q{}
                )
                : (
                    defined $plural
                    ? "$value $plural"
                    : defined $singular
                    ? "$value $singular"
                    : q{}
                );
        }

        return q{};
    };

    if ( $self->is_gettext_style() ) {
        $text =~ s{
            (
                \% (?: quant | \* )
                \(
                \% (\d+)              # $2: n
                , ( [^,]* )           # $3: singular
                (?: , ( [^,]* ) )?    # $4: plural
                (?: , ( [^,]* ) )?    # $5: zero
                \)
                |
                \% (\d+)              # $6: n
            )
        }
        {
            $replace->()
        }xmsge;
    }
    else {
        $text =~ s{
            (
                \[ (?:
                    (?: quant | \* )
                    , _ (\d+)            # $2: n
                    , ( [^,]* )          # $3: singular
                    (?: , ( [^,]* ) )?   # $4: plural
                    (?: , ( [^,]* ) )?   # $5: zero
                    |
                    _ (\d+)              # $6: n
                ) \]
            )
        }
        {
            $replace->()
        }xmsge;
    }

    return $text;
}

sub expand_gettext {
    my (undef, $text, %args) = @_;

    defined $text
        or return $text;

    my $regex = join q{|}, map { quotemeta $_ } keys %args;
    $text =~ s{
        \{ ($regex) \}
    }{
        defined $args{$1} ? $args{$1} : "{$1}"
    }xmsge;

    return $text;
}

no Moose;
__PACKAGE__->meta()->make_immutable();

1;

__END__

=head1 NAME

Locale::PO::Utils - Utils to build/extract the PO header and anything else

$Id: Utils.pm 520 2010-07-31 06:17:39Z steffenw $

$HeadURL: https://dbd-po.svn.sourceforge.net/svnroot/dbd-po/Locale-PO-Utils/trunk/lib/Locale/PO/Utils.pm $

=head1 VERSION

0.05

=head1 SYNOPSIS

    use Locale::PO::Utils;

=head1 DESCRIPTION

Utils to build/extract the PO header and anything else.

=head1 SUBROUTINES/METHODS

=head2 method new

    my $obj = Locale::PO::Utils->new();

=head2 read/write header

=head3 method get_all_header_keys

This sub returns all header keys you can set or get.

    $array_ref = $obj->get_all_header_keys();

or as class method

    $array_ref => Locale::PO::Utils->get_all_header_keys();

The $array_ref is:

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
    ) ]

=head3 method build_header_msgstr

There are more ways to do this.

=head4 minimal header

    $obj->build_header_msgstr();

The result is:

 MIME-Version: 1.0
 Content-Type: text/plain; charset=UTF-8
 Content-Transfer-Encoding: 8bit

=head4 maximal header

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
    });

The result is:

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

=head3 method split_header_msgstr (for internal use only)

This method is internal used at method get_header_msgstr_data.

    $array_ref = $obj->split_header_msgstr($msgstr);

=head3 method get_header_msgstr_data

This method extracts the values using the given keys.

=head4 single mode

    $string = $obj->get_header_msgstr_data($msgstr, 'Project-Id-Version');

$string is now "Testproject".

=head4 multiple mode

    $data = $obj->get_header_msgstr_data(
        $msgstr,
        [qw(Project-Id-Version Report-Msgid-Bugs-To-Mail extended)],
    ),

$data is now:

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
    ]

=head2 method set_plural_forms

Plural forms are defined like that for English

    $obj->set_plural_forms('nplurals=2; plural=n != 1');

=head3 method calculate_plural_forms

This method sets the nplural count and the plural code in a safe way.

    $obj->calculate_plural_forms();

=head3 method get_nplurals

This method get back the calculated count of plural forms.
The default value before any calculation is 1.

    $nplurals = $obj->get_nplurals();

=head3 method get_plural_code

This method get back the calculated code for the calculaded plural form
to select the right plural.
The default value before any calculation sub {return 0}.

For the example 'nplurals=2; plural=n != 1':

    $plural = $obj->get_plural_code()->(0), # $plural is 1
    $plural = $obj->get_plural_code()->(1), # $plural is 0
    $plural = $obj->get_plural_code()->(2), # $plural is 1
    $plural = $obj->get_plural_code()->(3), # $plural is 1
    ...

=head2 different writing of placeholders

=head3 method maketext_to_gettext

Maps maketext strings with
[_1]
or [quant,_1,singular,plural,zero]
or [*,_1,singular,plural,zero]
inside
to %1
or %quant(%1,singluar,plural,zero]
or %*(%1,singluar,plural,zero]
inside.

    $gettext_string = $obj->maketext_to_gettext($maketext_string);

or

    @gettext_strings = $obj->maketext_to_gettext(@maketext_strings);

This method can called as class method too.

    $gettext_string = Locale::PO::Utils->maketext_to_gettext($maketext_string);

or

    @gettext_strings = Locale::PO::Utils->maketext_to_gettext(@maketext_strings);

=head2 expand placeholders

=head3 method expand_maketext

Expands strings containing maketext placeholders.
If the fist parameter is true,
gettext style is used instead of maketext style.

maketext style:

 [_1]
 [quant,_1,singular,plural,zero]
 [*,_1,singular,plural,zero]

gettext style:

 %1
 %quant(%1,singular,plural,zero)
 %*(%1,singular,plural,zero)

    $obj->set_is_gettext_style(0);
    $expanded = $obj->expand_maketext($maketext_text, @args);

    $obj->set_is_gettext_style(1);
    $expanded = $obj->expand_maketext($gettext_text, @args);

=head3 method expand_gettext

Expands strings containing gettext placeholders like {name}.

    $expanded = $obj->expand_gettext($text, %args);

This method can called as class method too.

    $expanded = Locale::PO::Utils->expand_gettext($text, %args);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run the *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

Moose

L<MooseX::StrictConstructor|MooseX::StrictConstructor>

L<MooseX::FollowPBP|MooseX::FollowPBP>

English

Carp

Clone

L<Params::Validate|Params::Validate>

Safe

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
