use 5.010;
use strict;
use warnings;

sub tokenize {
	chomp(my $expr = shift);
	my @res;

	my @chunks = split m{([-+*/^()])}, $expr;

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
