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

sub _reduce_func($) {
  my ($self, $res, $row) = @_;
  my $field = $self -> {field};
  my $a = $row -> get($field, 0);
  if ($res -> {num} == 0) {
    $res -> {min} = $a;
    $res -> {max} = $a;
  } else {
    $res -> {min} = min($res -> {min}, $a);
    $res -> {max} = max($res -> {max}, $a);
  }
  $res -> {sum} += $a;
  $res -> {num} ++;
  return $res;
}

1;
