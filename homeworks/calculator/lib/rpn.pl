=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

  my @ops;
	for my $s (@$source) {
		given ($s) {
			when (/\d/) {
				push @rpn, (0+$s)."";
			}
			when ('(') {
				push @ops, '(';
			}
			when (')') {
				my %index;
				@index{@ops} = (0..$#ops);
				if (exists $index{'('}) {
					my $index = $index{'('};
					push @rpn, reverse @ops[($index+1)..$#ops];
					@ops = @ops[0..($index-1)];
				} else {
					die "Bad: '$_'";
				}
			}
			when (['U+','U-']) {
				push @ops, $s;
			}
			when ('^') {
        push @ops, $s;
			}
			when (['*', '/']) {
				while(@ops && $ops[$#ops] =~ /^(U[-\+])|([\^\*\/])$/) {
					push @rpn, $ops[$#ops];
					@ops = @ops[0..$#ops-1];
				}
        push @ops, $s;
			}
			when (['+', '-']) {
				while(@ops && $ops[$#ops] =~ /^U?[-\^\*\/\+]$/) {
					push @rpn, $ops[$#ops];
					@ops = @ops[0..$#ops-1];
				}
        push @ops, $s;
			}
		}
	}
	push @rpn, reverse @ops;

	return \@rpn;
}

1;
