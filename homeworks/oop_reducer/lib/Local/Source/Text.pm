package Local::Source::Text;

use strict;
use warnings;
use parent 'Local::Source';

=encoding utf8
=head1 NAME
Local::Source::Text - get elements from text string
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
  my ($class, %params) = @_;
  my $delimeter = exists $params{delimeter} ? $params{delimeter} : "\n";
  my @array = split $delimeter, $params{text};
  my %res = ("array", \@array);
  return bless \%res, $class;
}

1;
