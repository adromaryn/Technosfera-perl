package Local::MusicLibrary;

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

use Exporter 'import';
use List::Util qw(max sum);

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub mus_input() {
  my @data;
  while (<>) {
    my $song = mus_split($_);
    push @data, $song;
  }
  return \@data;
}

sub mus_split($) {
  my @a = split "/", shift @_;
  my @song;
  push @song, $a[1];
  push @song, split " - ", $a[2], 2;
  my @file = split /\./, $a[-1];
  push @song, join(".", @file[0 .. $#file - 1]), $file[-1];
  chomp $song[-1];
  return \@song;
}

sub col_width(@) {
  my @width;
  for (my $i = 0; $i < @{ $_[0] }; $i++){
    my @col = map $_->[ $i ], @_;
    push @width, max(map length($_), @col) + 2;
  }
  return \@width;
}

sub wall(@) {
  return "|" . (join "+", map("-"x$_, @_)) . "|";
}

sub top(@) {
  return "/" . ("-" x (sum(@_) + $#_)) . "\\";
}

sub bottom(@) {
  return "\\" . ("-" x (sum(@_) + $#_)) . "/";
}

sub raw($$){
  my @strings = @{ shift @_ };
  my @width = @{ shift @_ };
  return "|" .
         (join "|", map(
           sprintf("%${width[$_]}s", $strings[$_] . " "),
           (0..$#strings)
         )) .
         "|";
}

sub mus_table(@){
  if (@_){
    my $width = col_width(@_);
    say top(@$width);
    for (my $i = 0; $i < @_; $i++) {
      say raw($_[$i], $width);
      if ($i != @_ - 1) {
        say wall(@$width);
      }
    }
    say bottom(@$width);
  } else {
    print "\n";
  }
}

sub mus_sort($$$) {
  my @data = @{ shift @_ };
  my $col = shift @_;
  my $is_num = shift @_;
  if ($is_num) {
    @data = sort { @{ $a }[$col] <=> @{ $b }[$col] } @data;
    return \@data;
  } else {
    @data = sort { @{ $a }[$col] cmp @{ $b }[$col] } @data;
    return \@data;
  }
}

sub mus_grep($$$$) {
  my @data = @{ shift @_ };
  my $col = shift @_;
  my $filter = shift @_;
  my $is_num = shift @_;
  if ($is_num) {
    @data = grep @{ $_ }[$col] == $filter, @data;
    return \@data;
  } else {
    @data = grep @{ $_ }[$col] eq $filter, @data;
    return \@data;
  }
}

sub mus_columns($$) {
  my @data = @{ shift @_ };
  my @col = @{ shift @_ };
  my @res;
  for my $d (@data) {
    push @res, [ map @{ $d }[$_], @col ];
  }
	return \@res;
}

our @EXPORT = qw(mus_input mus_split mus_table mus_sort mus_grep mus_columns);

1;
