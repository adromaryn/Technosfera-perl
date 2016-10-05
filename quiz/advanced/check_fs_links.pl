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

sub checkRing($) {
  my $l = shift;
  my $link = File::Spec->rel2abs(readlink $l);
  if (index($l, $link) != -1) {
    say "$l ---> $link - ring";
  }
}

sub checkOutside($$) {
  my $root = shift;
  my $l = shift;
  my $link = File::Spec->rel2abs(readlink $l);
  if (index($link, $root) == -1) {
    say "$root: $l ---> $link - outside";
  }
}

sub check($$$);

sub check($$$) {
  my $parent = shift;
  my $dirname = shift;
  my $ignore_sym = shift;
  opendir(my $dir, $dirname);
  while (my $file = readdir($dir)) {
    if (-l $dirname . '/' . $file) {
      checkRing($dirname . '/' . $file);
      checkOutside($parent, $dirname . '/' . $file);
    } elsif (-d $dirname . '/' . $file && $file ne "." && $file ne "..") {
      check($parent, $dirname . '/' . $file, $ignore_sym);
    }
  }
  closedir $dir;
}

my $dirname = File::Spec->rel2abs($ARGV[-1]);
print $dirname."\n";
check($dirname, $dirname, "");
