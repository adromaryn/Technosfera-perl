package Local::MusicLibrary::View;

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

sub mus_columns($$) {
  my $data = shift @_;
  my $col = shift @_;
  my $res;
  if (+@$col ne 0) {
		for my $d (@$data) {
      push @$res, [ map { @{ $d }[$_] } @$col ];
    }
	}
	return $res;
}

our @EXPORT = qw(mus_columns);

1;
