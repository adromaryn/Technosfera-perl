#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
	push @INC, './lib', '../lib';
}
no warnings 'experimental';

use Local::MusicLibrary;
use Getopt::Long qw(GetOptions);

my $sort;
GetOptions('sort=s' => \$sort) or die "Sort usage: $0 --sort NAME\n";
my $data = mus_input();
my @data;
if ($sort) {
  my %sort_hash = (
	  "band"   => 0,
		"year"   => 1,
		"album"  => 2,
		"track"  => 3,
		"format" => 4
	);
	$data = mus_sort($data, $sort_hash{$sort}, $sort eq "year");
}
mus_table(@$data);
