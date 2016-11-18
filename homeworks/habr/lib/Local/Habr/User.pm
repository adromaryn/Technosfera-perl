package Local::Habr::User;

use strict;
use warnings;

use Mouse;
use LWP::UserAgent;
#install LWP::Protocol::https
use HTML::TreeBuilder::XPath;
use Local::Habr::Post;
use Local::Habr::DB;
use Local::Habr::Cache;
use JSON::XS;
use utf8;
use Encode qw(decode);

has name   => (is => 'ro', isa => 'Str', required => 1);
has karma  => (is => 'ro', isa => 'Num', required => 1);
has rating => (is => 'ro', isa => 'Num', required => 1);

sub get_by_name {
    my $pkg = shift;
    my $name = shift;
    my $refresh = shift;
    my $dbh = Local::Habr::DB->instance()->{DB};
    my $memd = Local::Habr::Cache->instance()->{memd};
    if ($memd and my $val = $memd->get($name) and not $refresh) {
        my $user = decode_json $val;
        return $pkg->new(
            name   => $name,
            karma  => $user->{karma},
            rating => $user->{rating}
        );
    } else {
        my $sth = $dbh->prepare(
            'SELECT * FROM users WHERE name = ?'
        );
        $sth->execute($name);
        my $usr = $sth->fetchrow_hashref();
        if ($usr and not $refresh) {
            $memd->set("$name", encode_json {karma => $usr->{karma}, rating => $usr->{rating}}) if $memd;
            return $pkg->new(
                name   => $name,
                karma  => $usr->{karma},
                rating => $usr->{rating}
            );
        } else {
            my $browser = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
            my $url = "https://habrahabr.ru/users/$name";
            my $response = $browser->get( $url );
            if ($response->is_success) {
                my $str= $response->content;
                my $tree = HTML::TreeBuilder::XPath->new_from_content($str);
                my @karma = $tree->findvalues('//div[ @class = "voting-wjt__counter-score js-karma_num" ]');
                my $karma;
                if (@karma) {
                    $karma = join '.', (split ',', decode("utf8", $karma[0]));
                    $karma =~ s/–/-/;
                    $karma = 0 + $karma;
                } else {
                    $karma = 0;
                }
                my @rating = $tree->findvalues('//div[ @class = "statistic statistic_user-rating" ]//div[ @class = "statistic__value statistic__value_magenta" ]');
                my $rating;
                if (@rating) {
                    $rating = 0 + (join '.' , (split ',', $rating[0]));
                } else {
                    $rating = 0;
                }
                my $user = $dbh->prepare(
                    'REPLACE INTO users (name, karma, rating) VALUES (?, ?, ?)'
                );
                $user->execute($name, $karma, $rating);
                $memd->set($name, encode_json {karma => $karma, rating => $rating})  if $memd;
                return $pkg->new(
                    name   => $name,
                    karma  => $karma,
                    rating => $rating
                );
            } else {
                return undef;
            }
        }
    }
}

sub get_by_post {
    my $pkg = shift;
    my $post_id = shift;
    my $refresh = shift;
    my $post = Local::Habr::Post->get($post_id, $refresh, 1);
    if ($post) {
        return $pkg->get_by_name($post->{author}, $refresh);
    } else {
        return undef;
    }
}

sub get_selfers {
    my $pkg = shift;
    my $dbh = Local::Habr::DB->instance()->{DB};
    my $sth = $dbh->prepare(
        'SELECT name, karma, users.rating FROM commenters JOIN users JOIN posts ' .
        'ON commenters.post = posts.id AND posts.author = users.name and users.name = commenters.author'
    );
    $sth->execute();
    my $selfers = [map {$pkg->new($_)} @{$sth->fetchall_arrayref({})}];
    return $selfers;
}

sub get_commenters {
    my $pkg = shift;
    my $post = shift;
    my $refresh = shift;
    my $commenters = Local::Habr::Commenter->get_by_post($post, $refresh, 1);
    return [map { Local::Habr::User->get_by_name($_->{author}, $refresh) } @$commenters];
}

1;
