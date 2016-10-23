package Local::Reducer;

use strict;
use warnings;
use Local::Row::Simple;
use Local::Row::JSON;

=encoding utf8
=head1 NAME
Local::Reducer - base abstract reducer
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
  my ($class, %params) = @_;
  my ($source, $row_class, $initial_value) = @params{qw(source row_class initial_value)};

  delete @params{qw(initial_value)};
  $params{reduced} = $initial_value;
  return bless \%params, $class;
}

sub _reduce_func($) {
  my ($self, $res, $row) = @_;
  my $field = $self -> {field};
  return $row -> get($field, 0);
}

sub reduce_n {
  my ($self, $n) = @_;
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $res = $self -> {reduced};
  for (0..$n-1) {
    my $s = $source -> next();
    die "Local::Reducer::Sum: can't reduce_n, you haven't $n elements" if not defined $s;
    my $row = $row_class -> new(str => $s);
    $res = $self -> _reduce_func($res, $row);
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduce_all {
  my ($self, $n) = @_;
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my $res = $self -> {reduced};
  my $s;
  while (defined ($s = $source -> next())) {
    my $row = $row_class -> new(str => $s);
    $res = $self -> _reduce_func($res, $row);
  }
  $self -> {reduced} = $res;
  return $res;
}

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

1;
