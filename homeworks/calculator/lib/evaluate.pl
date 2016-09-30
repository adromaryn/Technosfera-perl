=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;

  my @stack;
	for my $r (@$rpn) {
		given ($r) {
			when (/\d/) {
				push @stack, (0+$r);
			}
			when ('U-') {
				$stack[$#stack] *= -1;
			}
			when ('U+') {}
			when ('^') {
        my $pow = $stack[$#stack-1] ** $stack[$#stack];
				@stack = @stack[0..$#stack-2];
				push @stack, $pow;
			}
			when ('*') {
        my $mul = $stack[$#stack-1] * $stack[$#stack];
				@stack = @stack[0..$#stack-2];
				push @stack, $mul;
			}
			when ('/') {
        my $div = $stack[$#stack-1] / $stack[$#stack];
				@stack = @stack[0..$#stack-2];
				push @stack, $div;
			}
			when ('+') {
        my $sum = $stack[$#stack-1] + $stack[$#stack];
				@stack = @stack[0..$#stack-2];
				push @stack, $sum;
			}
			when ('-') {
        my $dif = $stack[$#stack-1] - $stack[$#stack];
				@stack = @stack[0..$#stack-2];
				push @stack, $dif;
			}
		}
	}

	return $stack[$#stack];
}

1;
