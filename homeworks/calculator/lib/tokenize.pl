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

	my $flag = 0;
	my $i = 0;
	while ($expr) {
		if (!$flag) {
			if (substr($expr, 0, 1) =~ /^\+|-$/ ) {
				push @res, "U".substr($expr, 0, 1);
				$flag = 2;
			} elsif (substr($expr, 0, 1) =~ /^\d$/) {
				$flag = 1;
				push @res, substr($expr, 0, 1);
			} else {
				die "Invalid char, +/- or digit should be, position: ".$i;
			}
		} elsif ($flag == 1) {
			if (substr($expr, 0, 1) =~ /^\+|-|\*|\/$/ ) {
				push @res, substr($expr, 0, 1);
				$flag = 0;
			} elsif (substr($expr, 0, 1) =~ /^\d$/) {
				@res[$#res] = @res[$#res].substr($expr, 0, 1);
			} else {
				die "Invalid char, +/-/*// or digit should be, position: ".$i;
			}
		} else {
			if (substr($expr, 0, 1) =~ /^\d$/) {
				$flag = 1;
				push @res, substr($expr, 0, 1);
			} else {
				die "Invalid char, digit should be, position: ".$i;
			}
		}
		$expr = substr $expr, 1, (length($expr) - 1);
		$i++;
	}

	if ($flag != 1) {
		die "Last char should be digit";
	}

	return \@res;
}

1;
