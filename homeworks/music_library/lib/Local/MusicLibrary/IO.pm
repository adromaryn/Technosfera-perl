package Local::MusicLibrary::IO;

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
use Local::MusicLibrary::Utils;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my @fields = qw(band year album track format);

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
  my %song;
	$song{ band } = $a[1];
  $song{ year } = (split " - ", $a[2], 2)[0];
	$song{ album } = (split " - ", $a[2], 2)[1];
  my @file = split /\./, $a[-1];
	$song{ track } = join(".", @file[0 .. $#file - 1]);
	$song{ format } = $file[-1];
	chomp $song{ format };
  return \%song;
}

sub col_width(@) {
  my %width;
  for my $key ( keys %{ $_[0] } ){
    my @col = map {$_->{ $key }} @_;
    $width{ $key } = max(map length($_), @col) + 2;
  }
  return \%width;
}

sub wall($$) {
	my $width = shift;
	my $cols = shift;
  return "|" . (join "+", map { "-"x %$width{$_} } @$cols) . "|";
}

sub top($$) {
	my $width = shift;
	my $cols = shift;
  return "/" . ("-" x (sum(map {$width -> {$_}} @$cols) + @$cols - 1)) . "\\";
}

sub bottom($$) {
	my $width = shift;
	my $cols = shift;
  return "\\" . ("-" x (sum(map {$width -> {$_}} @$cols) + @$cols - 1)) . "/";
}

sub raw($$$){
	my $items = shift;
	my $width = shift;
	my $cols = shift;

  return "|".
         (join "|",
				   map { (" " x ($width->{$_} - length($items->{$_}) - 1) . $items->{$_} . " ") } @$cols
         ) .
         "|";
}

sub mus_table($$){
	my $data = shift @_;
	my $params = shift @_;
	for my $field (@fields) {
		if ($params->{ $field }) {
			mus_grep($data, $field, $params->{ $field }, $field eq "year");
		}
	}
  if (@$data){
    my $width = col_width(@$data);
		if ($params->{ sort }) {
			mus_sort($data, $params->{ sort }, $params->{ sort } eq "year");
		}
		my @cols;
		if ($params->{ columns }) {
			@cols = split "," , $params->{ columns };
		} elsif (defined $params->{ columns }) {
			print "";
		} else {
			@cols = qw(band year album track format);
		}
		if (not defined $params->{ columns } or $params->{ columns }) {
			say top($width, \@cols);
	    for (my $i=0; $i < @$data; $i++) {
	      say raw(@$data[$i], $width, \@cols);
	      if ($i != @$data - 1) {
	        say wall($width, \@cols);
	      }
	    }
	    say bottom($width, \@cols);
		}
  } else {
    print "";
  }
}

our @EXPORT = qw(mus_input mus_split mus_table);

1;
