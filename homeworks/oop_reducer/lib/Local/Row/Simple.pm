package Local::Row::Simple;

use strict;
use warnings;
use parent 'Local::Row';

=encoding utf8
=head1 NAME
Local::Source::Simple - parse simple strings
=head1 VERSION
Version 1.00
=cut

sub new {
  my ($class, %params) = @_;
  my @strings = split ",", $params{str};
  my %data;
  for my $str (@strings) {
    my ($key, $value) = split ":", $str;
    $data{$key} = $value;
  }
  my %res = ("data",\%data);
  return bless \%res, $class;
}

1;
