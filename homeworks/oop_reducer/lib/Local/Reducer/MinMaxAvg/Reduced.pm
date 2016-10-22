package Local::Reducer::MinMaxAvg::Reduced;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::Reducer::MinMaxAvg::Reduced - save min, max and average elements
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
  my ($class) = @_;
  my %params = (sum => 0, num => 0, min => 0, max => 0);
  return bless \%params, $class;
}

sub get_max {
  my ($self) = @_;
  return $self -> {max};
}

sub get_min {
  my ($self) = @_;
  return $self -> {min};
}

sub get_avg {
  my ($self) = @_;
  die "couldn't have average from 0 elements" if ($self -> {num} == 0);
  return ($self -> {sum})/($self -> {num});
}

1;
