package Local::Reducer::Sum;

use strict;
use warnings;
use parent 'Local::Reducer';
use feature 'say';

=encoding utf8
=head1 NAME
Local::Reducer::Sum - reducer for sum with field
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub reduce_n {
  my ($self, $n) = @_;
  my @arr = @{ $self -> {array} };
  my $field = $self -> {field};
  my $res = $self -> {reduced};
  for my $i (0..$n-1) {
    $res += $arr[$i] -> get($field, 0);
  }
  $self -> {reduced} = $res;
  $self -> {array} = [@arr[$n..$#arr]];
  return $res;
}

sub reduce_all {
  my ($self, $n) = @_;
  my @arr = @{ $self -> {array} };
  return $self -> reduce_n($#arr+1);
}