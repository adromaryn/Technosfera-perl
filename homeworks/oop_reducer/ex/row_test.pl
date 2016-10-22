#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Local::Row::Simple;
use Local::Row::JSON;

my $row = Local::Row::Simple -> new(str => "doctor?:1,who:2");

say $row -> get("doctor?",0);
say $row -> get("who",0);
say $row -> get("exterminate!",0);

my $json = Local::Row::JSON -> new(str => '{"doctor":"who", "hello": "world"}');

say $json -> get("doctor",0);
say $json -> get("hello",0);
say $json -> get("exterminate!",0);
