#!/usr/bin/perl

use strict;
use warnings;
use Data::MessagePack;
use JSON::XS;
use Benchmark qw/ :hireswallclock cmpthese /;

my $json     = JSON::XS->new;
my $msgpack  = Data::MessagePack->new;

my $stringData = {
    "glossary" => {
        "title"    => "example glossary",
        "GlossDiv" => {
            "title"     => "S",
            "GlossList" => {
                "GlossEntry" => {
                    "ID"        => "SGML",
                    "SortAs"    => "SGML",
                    "GlossTerm" => "Standard Generalized Markup Language",
                    "Acronym"   => "SGML",
                    "Abbrev"    => "ISO 8879=>1986",
                    "GlossDef"  => {
                        "para" =>
                            "A meta-markup language, used to create markup languages such as DocBook.",
                        "GlossSeeAlso" => [ "GML", "XML" ]
                    },
                    "GlossSee" => "markup"
                }
            }
        }
    }
};

my $numberData = [
    [ 1,  2,  3,  4,  -1, 1,     undef ],
    [ 3,  6,  5,  4,  1,  0,     7 ],
    [ 3,  2,  8,  1,  0,  1,     0 ],
    [ 10, 11, 12, 13, 14, 0,     1 ],
    [ 15, 16, 17, 18, 19, 1,     undef ],
    [ 20, 21, 22, 23, 24, undef, 7 ],
    [ 25, 26, 27, 28, 29, undef, 0 ],
    100, 200, 300,
    [   [ 1, 0, 0, 0, 0 ],
        [ 0, 1, 0, 0, 0 ],
        [ 0, 0, 1, 0, 0 ],
        [ 0, 0, 0, 1, 0 ],
        [ 0, 0, 0, 0, 1 ]
    ]
];

my $alphaNumber = {
    stringData => $stringData,
    numberData => $numberData
};

my $big = {};

for(0..1000) {
    $big->{ 'data_' . $_ } = $alphaNumber;
}

print "\nCompare STRING data only.\n";

### String
cmpthese(
    -1,
    {   'json_string' => sub {
            my $result = $json->decode( $json->encode($stringData) );
        },
        'msgpack_string' => sub {
            my $result = $msgpack->decode( $msgpack->encode($stringData) );
        }
    }
);

print "\n\nCompare NUMBERS data only.\n";

## Numbers
cmpthese(
    -1,
    {   'json_number' => sub {
            my $result = $json->decode( $json->encode($numberData) );
        },
        'msgpack_number' => sub {
            my $result = $msgpack->decode( $msgpack->encode($numberData) );
        }
    }
);

print "\n\nCompare STRING and NUMBERS data.\n";

## alphaNumber
cmpthese(
    -1,
    {   'json_alphaNumber' => sub {
            my $result = $json->decode( $json->encode($alphaNumber) );
        },
        'msgpack_aplhaNumber' => sub {
            my $result = $msgpack->decode( $msgpack->encode($alphaNumber) );
        }
    }
);

print "\n\nCompare a BIG data (1000 x string and numbers data size).\n";

## Big
cmpthese(
    -1,
    {   'json_big' => sub {
            my $result = $json->decode( $json->encode($big) );
        },
        'msgpack_big' => sub {
            my $result = $msgpack->decode( $msgpack->encode($big) );
        }
    }
);

print "\n";
exit 1;

__END__




