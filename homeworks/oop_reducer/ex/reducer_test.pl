#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Local::Reducer;
use Local::Reducer::Sum;
use Local::Source::Array;
use Local::Source::Text;

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
