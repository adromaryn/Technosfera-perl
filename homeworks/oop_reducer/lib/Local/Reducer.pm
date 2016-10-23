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

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

sub reduce_n {
  my ($self, $n) = @_;
  my $source = $self -> { source };
  my $row_class = $self -> { row_class };
  my @arr;
  if (defined $self -> {array}) {
    @arr = @{ $self -> {array} };
    $self -> {array} = undef;
  } else {
    for (0..$n-1) {
      my $s = $source -> next();
      die "Local::Reducer: can't reduce_n, you haven't $n elements" if not defined $s;
      push @arr, $row_class -> new(str => $s);
    }
  }
  return \@arr;
}

sub reduce_all {
  my ($self) = @_;
  my @arr;
  while (1) {
    my $elem = $self -> {source} -> next();
    if ($elem) {
      push @arr, $self -> {row_class} -> new(str => $elem);
    } else {
      last;
    }
  }
  $self -> {array} = \@arr;
  return $self -> reduce_n($#arr+1);
}

1;
