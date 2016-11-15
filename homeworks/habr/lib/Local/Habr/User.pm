package Local::Habr::User;

use strict;
use warnings;

use Mouse;
use LWP::UserAgent;
#install LWP::Protocol::https
use HTML::TreeBuilder::XPath;
use Local::Habr::Post;
use JSON::XS;

has name   => (is => 'ro', isa => 'Str', required => 1);
has karma  => (is => 'ro', isa => 'Int', required => 1);
has rating => (is => 'ro', isa => 'Int', required => 1);

sub get_by_name {
    my $pkg = shift;
    my $name = shift;
    my $dbh = shift;
    my $refresh = shift;
    my $memd = shift;
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
                    $karma = int((split ',', $karma[0])[0]);
                } else {
                    $karma = 0;
                }
                my @rating = $tree->findvalues('//div[ @class = "voting-wjt__counter-score js-karma_num" ]');
                my $rating;
                if (@rating) {
                    $rating = int((split ',', $karma[0])[0]);
                } else {
                    $rating = 0;
                }
                my $del = $dbh->prepare(
                    'DELETE FROM users WHERE name=?'
                );
                $del->execute($name);
                my $user = $dbh->prepare(
                    'INSERT INTO users (name, karma, rating) VALUES (?, ?, ?)'
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
    my $dbh = shift;
    my $refresh = shift;
    my $memd = shift;
    my $post = Local::Habr::Post->get($post_id, $dbh, $refresh);
    if ($post) {
        return $pkg->get_by_name($post->{author}, $dbh, $refresh, $memd);
    } else {
        return undef;
    }
}

sub get_selfers {
    my $pkg = shift;
    my $dbh = shift;
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
    my $dbh = shift;
    my $refresh = shift;
    my $commenters = Local::Habr::Commenter->get_by_post($post, $dbh, $refresh);
    return [map { Local::Habr::User->get_by_name($_->{author}, $dbh, $refresh) } @$commenters];
}

1;
