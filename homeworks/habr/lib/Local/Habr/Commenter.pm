package Local::Habr::Commenter;

use strict;
use warnings;

use Mouse;
use LWP::UserAgent;
#install LWP::Protocol::https
use HTML::TreeBuilder::XPath;
use JSON::XS;
use Local::Habr::Post;
use utf8;

has author   => (is => 'ro', isa => 'Str', required => 1);
has post    => (is => 'ro', isa => 'Int', required => 1);

sub get_by_post {
    my $pkg = shift;
    my $post = shift;
    my $refresh = shift;
    my $post_refresh = shift;
    my $dbh = Local::Habr::DB->get();
    my $sth = $dbh->prepare(
        'SELECT * FROM commenters WHERE post = ?'
    );
    $sth->execute($post);
    my $cm = $sth->fetchall_arrayref({});
    if (@{$cm} and not $refresh) {
        return [map {$pkg->new($_)} @{$cm}];
    } else {
        if ($post_refresh) {
            Local::Habr::Post->get($post, $refresh, "");
        }
        my $browser = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
        my $url = "https://habrahabr.ru/post/$post";
        my $response = $browser->get( $url );
        if ($response->is_success) {
            my $str= $response->content;
            my $tree = HTML::TreeBuilder::XPath->new_from_content($str);
            my @authors = $tree->findvalues('//a[ @class = "comment-item__username" ]');
            my $authors = [map {$pkg->new({author => $_, post => $post})} keys %{{map {$_ => 1} @authors}}];
            my $ins = $dbh->prepare(
                'REPLACE INTO commenters (author, post) VALUES (?, ?)'
            );
            for my $author (@$authors) {

                $ins->execute($author -> {author}, $post);
            }
            return $authors;
        } else {
            return undef;
        }
    }
}

1;
