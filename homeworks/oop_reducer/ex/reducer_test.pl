#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Local::Reducer;
use Local::Reducer::Sum;
use Local::Reducer::MaxDiff;
use Local::Source::Array;
use Local::Source::Text;
use Local::Source::FileHandler;

my $sreducer = Local::Reducer::Sum->new(
    field => 'price',
    source => Local::Source::Array->new(array => [
        '{"price": 1}',
        '{"price": 2}',
        '{"price": 3}',
        '{"price": 5}',
        '{"price": 10}'
    ]),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

say $sreducer -> reduce_n(2);
say $sreducer -> reduced;
say $sreducer -> reduce_n(1);
say $sreducer -> reduced;
say $sreducer -> reduce_all;
say $sreducer -> reduced;

say "";

my $reducer = Local::Reducer::MaxDiff->new(
    top => 'received',
    bottom => 'sended',
    source => Local::Source::Text->new(text =>"sended:1024,received:2048\nsended:2048,received:10240\nsended:9999,received:1100\nsended:10240,received:1024"),
    row_class => 'Local::Row::Simple',
    initial_value => 0,
);

say $reducer -> reduce_n(1);
say $reducer -> reduced;
say $reducer -> reduce_n(2);
say $reducer -> reduced;
say $reducer -> reduce_all;
say $reducer -> reduced;
