use strict;
use warnings;
use feature 'say';
use utf8;
binmode(STDOUT,':utf8');
use AnyEvent;
use AnyEvent::HTTP;
use HTML::TreeBuilder::XPath;
use URI;
use List::Util  qw(sum min);

my $NUM = 10000;
my $uri = "https://habrahabr.ru/";
#my $uri = "http://reddit.com";
my $host = URI->new($uri)->host;
my %hash = ();
my $counter = 1;

$AnyEvent::HTTP::MAX_PER_HOST = 100;
my $cv = AnyEvent->condvar;

sub async {
	my $link = shift;
	my $cb = shift;
	my $cr = shift;
	$counter++;
	say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; start";
	my $w; $w = http_get $link, sub {
		undef $w;
		my ($html) = @_;
		$cb->($link, $html, $cr+1);
		say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; exit";
		$counter--;
	};
}

my $next; $next = sub {
	my $link = shift;
	my $html = shift;
	my $c = shift;
	if (defined $html){
		$hash{$link} = length $html;
	  my $tree = HTML::TreeBuilder::XPath->new_from_content($html);
	  my @links = map {(split '\?' , ((split '#', $_)[0]))[0]}
		            grep {URI->new($_)->host eq $host or URI->new($_)->host eq "www.$host"}
			          grep {$_ =~ /^http/}
					  	  grep {defined $_}
	              map {$_->attr('href')} $tree->findnodes('//a');

	  for my $l (@links) {
		  if (not defined $hash{$l} and (my $size = keys %hash) < $NUM) {
				$hash{$l} = 0;
				async $l, sub {
					my $link = shift;
					my $html = shift;
			    my $c = shift;
					$next->($link, $html, $c);
				}, $c;
	    }
	  }
	}
};

$cv->begin;
my $guard; $guard = http_get $uri, sub {
	undef $guard;
	my ($res) = @_;
	$next->($uri, $res, 0);
	$counter--;
};

my $t; $t = AE::timer 1, 0.1, sub {
	if ($counter == 0 ) {
	  my $sum = sum(values %hash);
	  my $size = keys %hash;
	  say "Сумма размеров $size страниц: $sum bytes";
		my @keys = (sort { -($hash{$a} <=> $hash{$b}) } keys %hash)[0..min(9,$size-1)];
		say "Рейтинг:";
		foreach my $key (@keys) {
			my $s = $hash{$key};
			say "$key -> $s";
		}
		$cv->end;
		undef $t;
	}
};

$cv->recv;
