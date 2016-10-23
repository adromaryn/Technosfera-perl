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
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $field = $self -> {field};
  my $res = $self -> {reduced};
  my $top = $self -> {top};
  my $bottom = $self -> {bottom};
  for my $i (0..$n-1) {
    my $s = $source -> next();
    die "Local::Reducer::MaxDiff: can't reduce_n, you haven't $n elements" if not defined $s;
    my $a = $row_class -> new(str => $s);
    $res = max($res, abs($a -> get($top, 0) - $a -> get($bottom, 0)));
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduce_all {
  my ($self, $n) = @_;
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $field = $self -> {field};
  my $res = $self -> {reduced};
  my $top = $self -> {top};
  my $bottom = $self -> {bottom};
  my $s;
  while (defined ($s = $source -> next())) {
    my $a = $row_class -> new(str => $s);
    $res = max($res, abs($a -> get($top, 0) - $a -> get($bottom, 0)));
  }
  $self -> {reduced} = $res;
  return $res;
}

1;
