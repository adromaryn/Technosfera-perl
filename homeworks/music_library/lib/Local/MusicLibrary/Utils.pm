package Local::MusicLibrary::Utils;

use strict;
use warnings;
use 5.10.0;
BEGIN{
  if ($] < 5.018) {
    package experimental;
    use warnings::register;
  }
}
no warnings 'experimental';
our $VERSION = '1.00';

use Exporter 'import';


sub mus_grep($$$$) {
  my $data = shift @_;
  my $col = shift @_;
  my $filter = shift @_;
  my $is_num = shift @_;
  if ($is_num) {
    @$data = grep { $_ -> {$col} == $filter } @$data;
    return $data;
  } else {
    @$data = grep { $_ -> {$col} eq $filter } @$data;
    return $data;
  }
}

sub mus_sort($$$) {
  my $data = shift @_;
  my $col = shift @_;
  my $is_num = shift @_;
  if ($is_num) {
    @$data = sort { $a->{$col} <=> $b->{$col} } @$data;
    return $data;
  } else {
    @$data = sort { $a->{$col} cmp $b->{$col} } @$data;
    return $data;
  }
}

our @EXPORT = qw(mus_grep mus_sort);

1;
