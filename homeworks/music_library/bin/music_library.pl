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

use Local::MusicLibrary::IO;
use Local::MusicLibrary::Utils;
use Getopt::Long qw(GetOptions);

my %params;
GetOptions('sort=s' => \$params{ sort },
           'band=s' => \$params{ band },
					 'year=i' => \$params{ year },
					 'album=s' => \$params{ album },
					 'track=s' => \$params{ track },
					 'format=s' => \$params { format },
					 'columns=s', => \$params{ columns }) or
					 die "Usage: $0 [--sort COLUMN --band BAND --year YEAR --album ALBUM --track TRACK --format FORMAT --columns [COL1,COL2,...]]\n";
my $data = mus_input();
my %col_hash = (
	"band"   => 0,
	"year"   => 1,
	"album"  => 2,
	"track"  => 3,
	"format" => 4
);
mus_table($data, \%params);
