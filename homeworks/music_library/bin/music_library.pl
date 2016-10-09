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
my $band;
my $year;
my $album;
my $track;
my $format;
GetOptions('sort=s' => \$sort,
           'band=s' => \$band,
					 'year=i' => \$year,
					 'album=s' => \$album,
					 'track=s' => \$track,
					 'format=s' => \$format) or
					 die "Usage: $0 --sort COLUMN --band BAND --year YEAR --album ALBUM --track TRACK --format FORMAT\n";
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
if ($band) {
	$data = mus_grep($data, 0, $band, 0);
}
if ($year) {
	$data = mus_grep($data, 1, $year, 1);
}
if ($album) {
	$data = mus_grep($data, 2, $album, 0);
}
if ($track) {
	$data = mus_grep($data, 3, $track, 0);
}
if ($format) {
	$data = mus_grep($data, 4, $format, 0);
}
mus_table(@$data);
