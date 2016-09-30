=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	my @res;

	my @chunks = split m{([-+*/^()])}, $expr;
  #print print join(",", @chunks)."\n";

	for my $c (@chunks) {
		next if $c =~ /^\s*$/;
    $c=~s/\s//g;;
		given ($c) {
			when (/^\s*$/) {}
			when (/^\d*\.?\d*['e','E']?\d*$/) {
				if (@res && $res[$#res] =~ /^\d*\.?\d*['e','E'][-\+]$/ && $c =~ /^\d+$/) {
					$res[$#res] = $res[$#res].$c;
				} elsif (@res && $res[$#res] eq ')') {
					die "Bad: '$_'";
				} else {
					push @res, $c;
				}
			}
			when ([ '+','-' ]){
				if (@res == 0 || $res[$#res] =~ /^(U?[-\+]|[\*\^\/\(])$/) {
					push @res, "U".$c;
				} elsif (substr($res[$#res], -1) =~ /^[eE]$/) {
					$res[$#res] = $res[$#res].$c;
				} elsif ($res[$#res] =~ /\d/ || $res[$#res] eq ')') {
					push @res, $c;
				} else {
					die "Bad: '$_'";
				}
			}
			when (["*","/","^"]) {
				if (@res && ($res[$#res] =~ /\d/ || $res[$#res] eq ')') ) {
					push @res, $c;
				} else {
					die "Bad: '$_'";
				}
			}
			when (["("]) {
				if (@res && $res[$#res] =~ /\d/ ) {
					die "Bad: '$_'";
				} else {
					push @res, $c;
				}
			}
			when ([")"]) {
				if (!@res || $res[$#res] =~ /^U?[-\+\*\/\^]$/ ) {
					die "Bad: '$_'";
				} else {
					push @res, $c;
				}
			}
			default {
				die "Bad: '$_'";
			}
		}
	}

	if ($res[$#res] !~ /\d|\)/) {
		die "Bad: tokenize failed, last chunk not number or )";
	}

	return \@res;
}

1;
