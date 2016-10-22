package Local::Source::Array;

use strict;
use warnings;
use parent 'Local::Source';

=encoding utf8
=head1 NAME
Local::Source::Array - get elements of the array to reducer
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
  my ($class, %params) = @_;
  return bless \%params, $class;
}

1;
