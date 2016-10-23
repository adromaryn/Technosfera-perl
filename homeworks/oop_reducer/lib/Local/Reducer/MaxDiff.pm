package Local::Reducer::MaxDiff;

use strict;
use warnings;
use parent 'Local::Reducer';
use List::Util 'max';

=encoding utf8
=head1 NAME
Local::Reducer::Sum - reducer for finding max difference between fields
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub reduce_n {
  my ($self, $n) = @_;
  my @arr = @{ $self -> SUPER::reduce_n($n) };
  die "Local::Reducer::MaxDiff: can't reduce_n, you haven't $n elements" if (@arr < $n);
  my $top = $self -> {top};
  my $bottom = $self -> {bottom};
  my $res = $self -> {reduced};
  for my $i (0..$n-1) {
    $res = max($res, abs($arr[$i] -> get($top, 0) - $arr[$i] -> get($bottom, 0)));
  }
  $self -> {reduced} = $res;
  return $res;
}

1;
