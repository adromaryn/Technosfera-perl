package MusicLib::Helper::Table;

use strict;
use warnings;
use utf8;
use feature ':5.10';
use Exporter 'import';

sub parse {
  my $table = shift;
  my @lines = (split '\n', $table);
  my @res;
  if (@lines < 3) {
    return undef
  } else {
    @lines = @lines[map { $_ * 2 + 1} (0..@lines/2 - 1)];
    for my $line (@lines) {
      if (($line =~ /^\|\s*(.*)\s*\|\s*(.*)\s*\|\s*(.*)\s*\|\s*(.*)\s*\|\s*(.*)\s*\|\s*$/)) {
        push @res, {
          band  => $1,
          year   => $2,
          album   => $3,
          track  => $4,
          format => $5
        };
      } else {
        return undef;
      }
    }
    return \@res;
  }
}

our @EXPORT = qw(parse);

1;
