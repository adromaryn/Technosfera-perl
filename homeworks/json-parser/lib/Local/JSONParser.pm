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
  my $str = shift;
  if (not $str =~ /^(\s*(?:".*?(?:[^\\](?:\\\\)*)")\s*:\s*((?:[-\+]?\+?\d*?\.?\d*)|(?:(?:".*?(?:[^\\](?:\\\\)*)")|"")|(\{.*?\})|(\[.*?\]))\s*,?)*\s*$/s) {
    die "not a JSON: $str";
  }
  #/((?:".*?(?:[^\\](?:\\\\)*)")|"")/s - Регулярка для строки с экстраполяцией двойыных кавычек
  #используем её как кусок регулярки для вычленения пар ключ-значение
  # (?:[-\+]?\+?\d*?\.?\d*) - это число. с возможным унарным оператором и точкой
  # вычленяем пары ключ значение вида "ключ" : ("строка" или число или {хэш} или [массив])
  while ($str =~ /\s*(?:"(.*?(?:[^\\](?:\\\\)*))")\s*:\s*((?:[-\+]?\+?\d*?\.?\d*)|(?:(?:".*?(?:[^\\](?:\\\\)*)")|"")|(\{.*?\})|(\[.*?\]))\s*(?=,.*|$)/gsc) {
    my $key = $1;
    if ($2 =~ /^\s*(\".*?\")\s*$/s) {
      my $string = $1;
      $string =~ s/(?<=\\u....)/\}/;
      $string =~ s/\\u/\\x\{/;
      $res{$key} = eval($string);
    } elsif ($2 =~ /^\s*([-\+]?\+?\d*?\.?\d*)\s*$/s) {
      $res{$key} = 0+$1;
    } elsif ($2 =~ /^\s*\{(.*?)\}\s*$/s) {
      $res{$key} = parse_hash($1);
    } elsif ($2 =~ /^\s*\[(.*?)\]\s*$/s) {
      $res{$key} = parse_array($1);
    }
  }
  return \%res;
}

sub parse_array {
  my @res;
  my $str = shift;
  if (not $str =~ /^(?:(?:(?:".*?(?:[^\\](?:\\\\)*)")|"")|(?:[-\+]?\+?\d*?\.?\d*)|(?:\{.*\})|(?:\[.*\]))*,?\s*/s) {
    die "not a JSON: $str";
  }
  while ($str =~ /((?:(?:".*?(?:[^\\](?:\\\\)*)")|"")|(?:[-\+]?\+?\d*?\.?\d*)|(?:\{.*\})|(?:\[.*\]))\s*(?:,|$)/gsc) {
    if ($1 eq "") {
      last;
    }
    if ($1 =~ /^\s*(\".*?\")\s*$/s) {
      my $string = $1;
      $string =~ s/(?<=\\u....)/\}/;
      $string =~ s/\\u/\\x\{/;
      push @res, eval($string);
    } elsif ($1 =~ /^\s*([-\+]?\+?\d*?\.?\d*)\s*$/s) {
      push  @res, (0+$1);
    } elsif ($1 =~ /^\s*\{(.*?)\}\s*$/s) {
      push @res, parse_hash($1);
    } elsif ($1 =~ /^\s*\[(.*?)\]\s*$/s) {
      push @res, parse_array($1);
    }
  }
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
    die "not a JSON: $_";
  }
}

1;
