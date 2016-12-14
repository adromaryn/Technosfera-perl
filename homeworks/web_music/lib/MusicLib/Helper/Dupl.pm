package MusicLib::Helper::Dupl;

use strict;
use warnings;
use utf8;
use feature ':5.10';
use Exporter 'import';

sub is_dupl {
  my $str = shift;
  return $str =~ /Duplicate entry/
}

our @EXPORT = qw(is_dupl);

1;
