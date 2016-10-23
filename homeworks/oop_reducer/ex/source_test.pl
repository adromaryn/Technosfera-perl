#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Local::Source::Array;
use Local::Source::Text;
use Local::Source::FileHandler;

my $array = Local::Source::Array -> new(array => [7, 9, 8, 4, 5]);
for my $i (0..5) {
  my $r = $array -> next();
  if ($r) {
    say $r;
  } else {
    say 'undef';
  }
}
say "";

my $text = Local::Source::Text -> new(text => "sended:1024,received:2048\nsended:2048,received:10240");
for my $i (0..2) {
  my $r = $text -> next();
  if ($r) {
    say $r;
  } else {
    say 'undef';
  }
}

say "";

open(my $fh, "<:encoding(UTF-8)", "test")
    || die "Can't open UTF-8 encoded 'test': $!";

my $file = Local::Source::FileHandler -> new(fh => $fh);
for my $i (0..4) {
  my $r = $file -> next();
  if ($r) {
    say $r;
  } else {
    say 'undef';
  }
}

close($fh);
