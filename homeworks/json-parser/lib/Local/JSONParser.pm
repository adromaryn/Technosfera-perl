package Local::JSONParser;

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

use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

sub parse_hash {
  my %res;
  $_ = shift;
  #/((?:".*?(?:[^\\](?:\\\\)*)")|"")/s - Регулярка для строки с экстраполяцией двойыных кавычек
  #используем её как кусок регулярки для вычленения пар ключ-значение
  while (/\s*((?:".*?(?:[^\\](?:\\\\)*)")|"")\s*:\s*((?:[-\+]?\+?\d*?\.?\d*)|(?:(?:".*?(?:[^\\](?:\\\\)*)")|"")|(\{.*?\})|(\[.*?\]))\s*(?=,.*|$)/gsc) {
    my $key = $1;
    if ($2 =~ /^\s*\"(.*?)\"\s*$/s) {
      $res{$key} = $1;
    } elsif ($2 =~ /^\s*([-\+]?\+?\d*?\.?\d*)\s*$/s) {
      $res{$key} = 0+$1;
    } elsif ($2 =~ /^\s*\{(.*?)\}\s*$/s) {
      $res{$key} = parse_hash($1);
    }
  }
  return \%res;
}

sub parse_array {
  my @res;
  $_ = shift;
  say split /,/, $_;
  say $_;
  return \@res;
}

sub parse_json {
	my $source = shift;

	use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);
	if ($source =~ /^\s*\{(.*)\}\s*$/s){
    return parse_hash $1;
  } elsif($source =~ /^\s*\[(.*)\]\s*$/s){
    return parse_array $1;
  } else {
    return {};
  }
}

1;
