package Local::Source::FileHandler;

use strict;
use warnings;
use parent 'Local::Source';

=encoding utf8
=head1 NAME
Local::Source::FileHandler - get elements from the file
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

sub new {
  my ($class, %params) = @_;
  my $fh = $params{fh};
  my @array;
  while (readline($fh)) {
    chomp $_;
    push @array, $_;
  }

  my %res = ("array", \@array);
  return bless \%res, $class;
}

1;
