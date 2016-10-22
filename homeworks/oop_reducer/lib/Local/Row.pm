package Local::Row;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::Row - parse data from source (abstract)
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub get($$$) {
  my ($self, $name, $default) = @_;
  my $d = $self -> {data};
  my %data = %$d;
  if (exists $data{$name}) {
    return $data{$name};
  } else {
    return $default;
  }
}

1;
