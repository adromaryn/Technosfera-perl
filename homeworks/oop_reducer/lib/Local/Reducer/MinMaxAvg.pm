package Local::Reducer::MinMaxAvg;

use strict;
use warnings;
use parent 'Local::Reducer';
use List::Util 'max';
use List::Util 'min';

=encoding utf8
=head1 NAME
Local::Reducer::MinMaxAvg - reducer return min, max and average elements
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
  for my $i (0..$n-1) {
    my $s = $source -> next();
    die "Local::Reducer::MinMaxAvg: can't reduce_n, you haven't $n elements" if not defined $s;
    my $a = $row_class -> new(str => $s) -> get($field, 0);
    if ($res -> {num} == 0) {
      $res -> {min} = $a;
      $res -> {max} = $a;
    } else {
      $res -> {min} = min($res -> {min}, $a);
      $res -> {max} = max($res -> {max}, $a);
    }
    $res -> {sum} += $a;
    $res -> {num} ++;
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
  my $s;
  while (defined ($s = $source -> next())) {
    my $a = $row_class -> new(str => $s) -> get($field, 0);
    if ($res -> {num} == 0) {
      $res -> {min} = $a;
      $res -> {max} = $a;
    } else {
      $res -> {min} = min($res -> {min}, $a);
      $res -> {max} = max($res -> {max}, $a);
    }
    $res -> {sum} += $a;
    $res -> {num} ++;
  }
  $self -> {reduced} = $res;
  return $res;
}

1;
