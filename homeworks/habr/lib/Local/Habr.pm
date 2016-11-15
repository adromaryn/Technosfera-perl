package Local::Habr;

use strict;
use warnings;
use Local::Habr::Commenter;
use Local::Habr::User;
use Local::Habr::Post;
use JSON::XS;
use XML::Simple qw(:strict);
use Exporter 'import';
use utf8;
use Encode qw(decode);

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub user_by_name {
    my (%opts) = @_;
    my $name     = $opts{name};
    my $format   = $opts{format};
    my $refresh  = $opts{refresh};
    my $dbh      = $opts{db};
    my $memd     = $opts{memd};
    my $user = Local::Habr::User->get_by_name($name, $dbh, $refresh, $memd);
    if (not defined $user) {
        return undef;
    }
    if ($format eq 'json') {
        return encode_json { name => $user->{name}, rating => $user->{rating}, karma => $user->{karma}};
    } elsif ($format eq 'xml') {
        my $xs = XML::Simple->new();
        return $xs->XMLout({ name => $user->{name}, rating => $user->{rating}, karma => $user->{karma}});
    } else {
        die 'only json or xml output';
    }
}

sub user_by_post {
    my (%opts) = @_;
    my $post     = $opts{post};
    my $format   = $opts{format};
    my $refresh  = $opts{refresh};
    my $dbh      = $opts{db};
    my $memd     = $opts{memd};
    my $user = Local::Habr::User->get_by_post($post, $dbh, $refresh, $memd);
    if (not defined $user) {
        return undef;
    }
    if ($format eq 'json') {
        return encode_json { name => $user->{name}, rating => $user->{rating}, karma => $user->{karma}};
    } elsif ($format eq 'xml') {
        return XML::Simple->new(KeyAttr => {})->XMLout({ name => $user->{name}, rating => $user->{rating}, karma => $user->{karma}});
    } else {
        die 'only json or xml output';
    }
}

sub commenters_by_post {
    my (%opts) = @_;
    my $post     = $opts{post};
    my $refresh  = $opts{refresh};
    my $format   = $opts{format};
    my $dbh      = $opts{db};
    my $commenters = [
                   map  {{ name => $_->{name}, karma => $_->{karma}, rating => $_->{rating} }}
                   @{Local::Habr::User->get_commenters($post, $dbh, $refresh)}
               ];
    if ($format eq 'json') {
        return encode_json $commenters;
    } elsif ($format eq 'xml') {
        return XML::Simple->new(KeyAttr => {})->XMLout($commenters);
    } else {
        die 'only json or xml output';
    }
}

sub post_by_id {
    my (%opts) = @_;
    my $id       = $opts{id};
    my $format   = $opts{format};
    my $refresh  = $opts{refresh};
    my $dbh      = $opts{db};
    my $post = Local::Habr::Post->get($id, $dbh, $refresh);
    if (not defined $post) {
        return undef;
    }
    my $topic = decode("utf8", $post->{topic});
    if ($format eq 'json') {
        return encode_json {
            author => $post->{author},
            topic  => $topic,
            rating => $post->{rating},
            views  => $post->{views},
            stars  => $post->{stars}
        };
    } elsif ($format eq 'xml') {
        return XML::Simple->new(KeyAttr => {})->XMLout({
            author => $post->{author},
            topic  => $post->{topic},
            rating => $post->{rating},
            views  => $post->{views},
            stars  => $post->{stars}
        });
    } else {
        die 'only json or xml output';
    }
}

sub self_commentors {
    my (%opts) = @_;
    my $format   = $opts{format};
    my $dbh      = $opts{db};
    my $commenters = [
                   map  {{ name => $_->{name}, karma => $_->{karma}, rating => $_->{rating} }}
                   @{Local::Habr::User->get_selfers($dbh)}
               ];
    if ($format eq 'json') {
        return encode_json $commenters;
    } elsif ($format eq 'xml') {
        return XML::Simple->new(KeyAttr => {})->XMLout($commenters);
    } else {
        die 'only json or xml output';
    }
}

sub desert_posts {
    my (%opts) = @_;
    my $format   = $opts{format};
    my $dbh      = $opts{db};
    my $n        = $opts{n};
    my $commenters = [
                   map  {{
                       author => $_->{author},
                       topic  => decode("utf8", $_->{topic}),
                       rating => $_->{rating},
                       views  => $_->{views},
                       stars  => $_->{stars}
                   }}
                   @{Local::Habr::Post->desert($n, $dbh)}
               ];
    if ($format eq 'json') {
        return encode_json $commenters;
    } elsif ($format eq 'xml') {
        return XML::Simple->new(KeyAttr => {})->XMLout($commenters);
    } else {
        die 'only json or xml output';
    }
}


our @EXPORT = qw(user_by_name user_by_post commenters_by_post post_by_id self_commentors desert_posts);


1;
