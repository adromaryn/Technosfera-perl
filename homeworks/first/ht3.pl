use strict; use warnings;
use Data::Dumper;
use DDP;

my @arr;
while(<>) {
  chomp;
  push @arr, [ split /;/, $_ ];
}

print Dumper(@arr);
p @arr;
