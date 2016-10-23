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

sub _reduce_func($) {
  my ($self, $res, $row) = @_;
  my $field = $self -> {field};
  return $res + $row -> get($field, 0);
}

1;
