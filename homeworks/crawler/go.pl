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
#my $uri = "https://habrahabr.ru/";
#my $uri = "http://reddit.com";
my $uri = "http://perldoc.perl.org/";
my $host = URI->new($uri)->host;
my %hash = ();
my $counter = 1;

$AnyEvent::HTTP::MAX_PER_HOST = 100;
my $cv = AnyEvent->condvar;

sub say_stats {my $sum = sum(values %hash);
  my $size = grep {$hash{$_} != 0} keys %hash;
  say "Сумма размеров $size страниц: $sum bytes";
  my @keys = (sort { -($hash{$a} <=> $hash{$b}) } grep {$hash{$_} != 0} keys %hash)[0..min(9,$size-1)];
  say "Рейтинг:";
  foreach my $key (@keys) {
	  my $s = $hash{$key};
	  say "$key -> $s";
  }
}

sub async {
	my $link = shift;
	my $cb = shift;
	my $cr = shift;
	$counter++;
	say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; " .  (grep {$hash{$_} != 0} keys(%hash)) . " получено start" if $counter >= 0;
	my $w; $w = http_get $link, sub {
		undef $w;
		my ($body, $hdr) = @_;
    if ($hdr->{Status} !~ /^2|3/) {
      delete $hash{$link};
    } elsif ($hdr->{Redirect}) {
      delete $hash{$link};
      if(URI->new($hdr->{URL})->host eq $host) {
        $cb->($hdr->{URL}, $body, $cr+1);
      }
    } else {
      $cb->($link, $body, $cr+1);
    }
		say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; " .  (grep {$hash{$_} != 0} keys(%hash)) . " получено exit"  if $counter >= 0;
		$counter--;
		if ($counter == 0 or ((grep {$hash{$_} != 0} keys(%hash)) == $NUM and $counter > 0)) {
			$cv->end;
      $counter = -1;
			say_stats;
		}
	};
}

my $next; $next = sub {
	my $link = shift;
	my $html = shift;
	my $c = shift;
	if (defined $html  and (my $size = grep {$hash{$_} != 0} keys %hash) < $NUM){
		$hash{$link} = length $html;
	  my $tree = HTML::TreeBuilder::XPath->new_from_content($html);
	  my @links = map {$_ =~ /http/ ? $_ : ($_ =~ /^\// ? "http://$host"."$_" : "http://$host/$_") }
		            grep {($_ =~ /^http/) &&
								      (URI->new($_)->host eq $host or URI->new($_)->host eq "www.$host")
										  or $_ !~ /^#|(?:http)/}
					  	  grep {defined $_}
	              map {$_->attr('href')} $tree->findnodes('//a');

	  for my $l (@links) {
		  if (not defined $hash{$l} and (my $size = grep {$hash{$_} != 0} keys %hash) < $NUM) {
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
	if ($counter eq 0) {
		$cv->end;
		say_stats;
	}
};

$cv->recv;
