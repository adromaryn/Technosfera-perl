package Local::Source;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::Source - get data to reducer (abstract)
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub next {
  my ($self) = @_;
  my $arr = $self -> { array };
  if (@$arr) {
    my $elem = shift @$arr;
    $self -> { array } = $arr;
    return $elem;
  } else {
    return undef;
  }
}

1;
