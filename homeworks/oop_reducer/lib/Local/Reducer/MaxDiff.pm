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

sub _reduce_func($) {
  my ($self, $res, $row) = @_;
  my $top = $self -> {top};
  my $bottom = $self -> {bottom};
  return $res = max($res, abs($row -> get($top, 0) - $row -> get($bottom, 0)));
}

1;
