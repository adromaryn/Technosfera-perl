package Local::Habr::Post;

use strict;
use warnings;

use Mouse;
use LWP::UserAgent;
#install LWP::Protocol::https
use HTML::TreeBuilder::XPath;
use Local::Habr::Commenter;
use Local::Habr::DB;
use Local::Habr::Cache;
use JSON::XS;
use utf8;
use Encode qw(decode encode);

has author   => (is => 'ro', isa => 'Str', required => 1);
has topic    => (is => 'ro', isa => 'Str', required => 1);
has rating   => (is => 'ro', isa => 'Int', required => 1);
has views    => (is => 'ro', isa => 'Int', required => 1);
has stars    => (is => 'ro', isa => 'Int', required => 1);

sub get {
    my $pkg = shift;
    my $id = shift;
    my $refresh = shift;
    my $commenters_refresh = shift;
    if ($commenters_refresh) {
        Local::Habr::Commenter->get_by_post($id, $refresh, "");
    }
    my $dbh = Local::Habr::DB->get();
    my $sth = $dbh->prepare(
        'SELECT * FROM posts WHERE id = ?'
    );
    $sth->execute($id);
    my $pst = $sth->fetchrow_hashref();
    if ($pst and not $refresh) {
        delete $pst->{id};
        return $pkg->new($pst);
    } else {
        my $browser = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
        my $url = "https://habrahabr.ru/post/$id";
        my $response = $browser->get( $url );
        if ($response->is_success) {
            my $str= $response->content;
            my $tree = HTML::TreeBuilder::XPath->new_from_content($str);
            my @author = $tree->findvalues('//a[ @class = "post-type__value post-type__value_author" ]');
            my $author;
            if (@author) {
                #new habr corp blogs
                $author = substr $author[0], 1;
            } else {
                #old habr
                @author = $tree->findvalues('//a[ @class = "author-info__nickname" ]');
                $author = substr $author[0], 1;
            }
            my @topic = ($tree->findvalues('//h1[ @class = "post__title" ]//span'));
            my $topic;
            if (@topic == 1) {
                $topic = decode("utf8", $topic[0]);
            } else {
                $topic = decode("utf8", $topic[1]);
            }
            my @rating = ($tree->findvalues('//div[ @class = "post-additionals" ]//span[ @class = "voting-wjt__result-score js-score" ]'));
            if (@rating == 0) {
                #old habr
                @rating = ($tree->findvalues('//div[ @class = "post-additionals" ]//span[ @class = "voting-wjt__counter-score js-score" ]'));
            }
            my $rating = $rating[0];
            if ($rating ne '—') {
                $rating = int($rating);
            } else {
                $rating = 0;
            }
            my $views = ($tree->findvalues('//div[ @class = "views-count_post" ]'))[0];
            if ($views eq '—') {
                $views = 0;
            } elsif ($views =~ /^(.*)k$/) {
                $views = int(join ('.', split ',', $1))*1000;
            } else {
                $views = int(join ('.', split ',', $views));
            }
            my $stars = ($tree->findvalues('//span[ @class = "favorite-wjt__counter js-favs_count" ]'))[0];
            if ($stars ne '—') {
                $stars = int($stars);
            } else {
                $stars = 0;
            }
            my $post = $dbh->prepare(
                'REPLACE INTO posts (id, author, topic, rating, views, stars) VALUES (?, ?, ?, ?, ?, ?)'
            );
            $post->execute($id, $author, $topic, $rating, $views, $stars);
            return $pkg->new(
                author  => $author,
                topic   => $topic,
                rating  => $rating,
                views   => $views,
                stars   => $stars
            );
        } else {
            return undef;
        }
    }
}

sub desert {
    my $pkg = shift;
    my $num = shift;
    my $dbh = Local::Habr::DB->get();
    my $sth = $dbh->prepare(
        'SELECT author, topic, rating, views, stars' .
        ' FROM posts p WHERE (SELECT COUNT(*) FROM commenters WHERE (post = p.id)) > ?'
    );
    $sth->execute($num);
    my $selfers = [map {$pkg->new($_)} @{$sth->fetchall_arrayref({})}];
}

1;
