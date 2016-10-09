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

sub checkRing($$$);

sub checkRing($$$) {
	my $root = shift;
  my $l = shift;
	my $entry = shift;
  my $link = File::Spec->rel2abs(readlink $l);
  if (index($entry, $link) != -1) {
    say "$entry ---> $link - ring";
  } elsif (-l $link) {
		checkRing($root, $link, $entry);
		checkOutside($root, $link, $entry);
	} elsif (-d $link) {
		check($entry, $link);
	}
}

sub checkOutside($$$);

sub checkOutside($$$) {
  my $root = shift;
  my $l = shift;
	my $entry = shift;
  my $link = File::Spec->rel2abs(readlink $l);
  if (index($link, $root) == -1) {
    say "$root: $entry ---> $link - outside";
  } elsif (-l $link) {
		checkRing($root, $link, $entry);
		checkOutside($root, $link, $entry);
	} elsif (-d $link) {
		check($entry, $link);
	}
}

sub check($$);

sub check($$) {
  my $parent = shift;
  my $dirname = shift;
  opendir(my $dir, $dirname);
  while (my $file = readdir($dir)) {
    if (-l $dirname . '/' . $file) {
      checkRing($parent, ($dirname . '/' . $file), ($dirname . '/' . $file));
      checkOutside($parent, $dirname . '/' . $file, $dirname . '/' . $file);
    } elsif (-d $dirname . '/' . $file && $file ne "." && $file ne "..") {
      check($parent, $dirname . '/' . $file);
    }
  }
  closedir $dir;
}

my $dirname = File::Spec->rel2abs($ARGV[-1]);
print $dirname."\n";
check($dirname, $dirname);
