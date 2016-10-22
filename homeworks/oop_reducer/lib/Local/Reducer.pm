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

  my @str;
  while (1) {
    my $elem = $source -> next();
    if ($elem) {
      push @str, $elem;
    } else {
      last;
    }
  }
  my @arr = map {$row_class -> new(str => $_)} @str;

  delete @params{qw(source row_class initial_value)};
  $params{array} = \@arr;
  $params{reduced} = $initial_value;
  return bless \%params, $class;
}

sub reduced {
  my $self = shift;
  return $self->{reduced};
}

1;
