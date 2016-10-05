use 5.010;
use strict;
use warnings;
use diagnostics;
use File::Spec qw/rel2abs/;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

perl
sub reduce(&@) {
  my ($f, @list) = @_;

  return;
}

# returns 10
reduce {
  my ($sum, $i) = @_;
  $sum + $i;
} 1, 2, 3, 4;
