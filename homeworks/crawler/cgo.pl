use strict;
use warnings;
use feature 'say';
use utf8;
binmode(STDOUT,':utf8');
use HTML::TreeBuilder::XPath;
use URI;
use Coro;
use Coro::LWP;
use LWP::UserAgent;
use List::Util  qw(sum min);	

my $NUM = 10000;
#my $uri = "https://habrahabr.ru/";
#my $uri = "http://reddit.com";
my $uri = "http://perldoc.perl.org/";
#my $uri = "http://httpbin.org/redirect/6";
my $host = URI->new($uri)->host;
my %hash = ();
my $counter = 0;

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

my $next;

sub upload {
  my $link = shift;
  $counter++;
  say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; " .  (grep {$hash{$_} != 0} keys(%hash)) . " получено start" if $counter >= 0;
  my $ua = LWP::UserAgent->new(agent => 'Coro');
  my $res = $ua->get($link);
  if ($res->is_success) {
    my $fin = $res->request()->uri();
    if ($fin ne $link) {
      if (not defined $hash{$fin}) {
      	$hash{$fin} = 0;
      	$next->($fin, $res->content);
      }
    } else {
      $next->($fin, $res->content);
    }
  }
  say "$counter страниц в обработке, " . keys(%hash) . " всего запрошено; " .  (grep {$hash{$_} != 0} keys(%hash)) . " получено exit"  if $counter >= 0;
  $counter--;
  if ($counter == 0 or ((grep {$hash{$_} != 0} keys(%hash)) == $NUM and $counter > 0)) {
    $counter = -1;
    say_stats;
  }
}

$next = sub {
  my $link = shift;
  my $html = shift;
  if (defined $html  and (my $size = grep {$hash{$_} != 0} keys %hash) < $NUM){
    $hash{$link} = length $html;
    my $tree = HTML::TreeBuilder::XPath->new_from_content($html);
    my @links = map {$_ =~ /http/ ? $_ : ($_ =~ /^\// ? "http://$host"."$_" : "http://$host/$_") }
                grep {($_ =~ /^http/) && (URI->new($_)->host eq $host or URI->new($_)->host eq "www.$host")
										  or $_ !~ /^#|(?:http)/}
		grep {defined $_}
	        map {$_->attr('href')} $tree->findnodes('//a');
    for my $l (@links) {
      if (not defined $hash{$l} and (my $size = grep {$hash{$_} != 0} keys %hash) < $NUM) {
      	$hash{$l} = 0;
      	upload $l;
      }
    }
  }
};

upload $uri;

