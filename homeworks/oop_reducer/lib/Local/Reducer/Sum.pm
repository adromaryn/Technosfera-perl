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
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $field = $self -> {field};
  my $res = $self -> {reduced};
  for (0..$n-1) {
    my $s = $source -> next();
    die "Local::Reducer::Sum: can't reduce_n, you haven't $n elements" if not defined $s;
    $res += $row_class -> new(str => $s) -> get($field, 0);
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduce_all {
  my ($self) = @_;
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $field = $self -> {field};
  my $res = $self -> {reduced};
  my $s;
  while (defined ($s = $source -> next())) {
    $res += $row_class -> new(str => $s) -> get($field, 0);
  }
  $self -> {reduced} = $res;
  return $res;
}

1;
