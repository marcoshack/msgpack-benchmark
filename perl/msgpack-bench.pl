#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw/ gettimeofday tv_interval /;
use Data::MessagePack;
use JSON::XS;

my ($d1, $d2);
my $runTests = 1000;
my %rTimes = ();

my $stringData = {"glossary"=>{"title"=>"example glossary","GlossDiv"=>{"title"=>"S","GlossList"=>{"GlossEntry"=>{"ID"=>"SGML","SortAs"=>"SGML","GlossTerm"=>"Standard Generalized Markup Language","Acronym"=>"SGML","Abbrev"=>"ISO 8879=>1986","GlossDef"=>{"para"=>"A meta-markup language, used to create markup languages such as DocBook.","GlossSeeAlso"=>["GML","XML"]},"GlossSee"=>"markup"}}}}};

my $numberData = [
  [1, 2, 3, 4, -1, 1, undef],
  [3, 6, 5, 4,  1, 0, 7],
  [3, 2, 8, 1,  0, 1, 0],
  [10, 11, 12, 13,  14, 0, 1],
  [15, 16, 17, 18, 19, 1, undef],
  [20, 21, 22, 23,  24, undef, 7],
  [25, 26, 27, 28,  29, undef, 0],
  100, 200, 300,
  [
    [1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 0, 1, 0],
    [0, 0, 0, 0, 1]
  ]
];

my $misto = {
    stringData => $stringData,
    numberData => $numberData
};

my $bigData = {};

for (0..100) {
    $bigData->{'data'.$_} = {
        stringData => $stringData,
        numberData => $numberData
    }
}

my $json = JSON::XS->new;
my $msgpack = Data::MessagePack->new;


## MsgPack String
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $msgpack->decode($msgpack->encode($stringData));
}
$d2 = [gettimeofday];

$rTimes{msgpack_string} = int($runTests/tv_interval($d1, $d2));

## Json String
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $json->decode($json->encode($stringData));
}
$d2 = [gettimeofday];

$rTimes{json_string} = int($runTests/tv_interval($d1, $d2));



## MsgPack Number
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $msgpack->decode($msgpack->encode($numberData));
}
$d2 = [gettimeofday];

$rTimes{msgpack_number} = int($runTests/tv_interval($d1, $d2));

## Json Number
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $json->decode($json->encode($numberData));
}
$d2 = [gettimeofday];

$rTimes{json_number} = int($runTests/tv_interval($d1, $d2));



## MsgPack Misto
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $msgpack->decode($msgpack->encode($misto));
}
$d2 = [gettimeofday];

$rTimes{msgpack_misto} = int($runTests/tv_interval($d1, $d2));

## Json Misto
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $json->decode($json->encode($misto));
}
$d2 = [gettimeofday];

$rTimes{json_misto} = int($runTests/tv_interval($d1, $d2));



## MsgPack BigData
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $msgpack->decode($msgpack->encode($bigData));
}
$d2 = [gettimeofday];

$rTimes{msgpack_big} = int($runTests/tv_interval($d1, $d2));

## Json BigData
$d1 = [gettimeofday];
for (1..$runTests) {
    my $result = $json->decode($json->encode($bigData));
}
$d2 = [gettimeofday];

$rTimes{json_bigdata} = int($runTests/tv_interval($d1, $d2));




foreach my $k (sort { $rTimes{$b} <=> $rTimes{$a} } keys %rTimes) {
    printf("%s \t .......  %d op/sec\n", $k, $rTimes{$k});
}




