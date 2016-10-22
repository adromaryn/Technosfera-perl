package Local::Row::JSON;

use strict;
use warnings;
use JSON::XS;
use parent 'Local::Row';

=encoding utf8
=head1 NAME
Local::Source::JSON - parse JSON
=head1 VERSION
Version 1.00
=cut

sub new {
  my ($class, %params) = @_;
  my @strings = split ",", $params{str};
  my $data = JSON::XS->new->utf8->decode($params{str});
  my %res = ("data", $data);
  return bless \%res, $class;
}

1;
