package Local::Habr;

use strict;
use warnings;
use Local::Habr::Commenter;
use Local::Habr::User;
use Local::Habr::Post;
use Local::Habr::FormatFactory;
use Exporter 'import';
use utf8;

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
    my $user = Local::Habr::User->get_by_name($name, $refresh);
    if (not defined $user) {
        return undef;
    }
    my $obj = {
        name => $user->{name},
        rating => $user->{rating},
        karma => $user->{karma}
    };
    return Local::Habr::FormatFactory->new($format)->process($obj);
}

sub user_by_post {
    my (%opts) = @_;
    my $post     = $opts{post};
    my $format   = $opts{format};
    my $refresh  = $opts{refresh};
    my $user = Local::Habr::User->get_by_post($post, $refresh);
    if (not defined $user) {
        return undef;
    }
    my $obj = {
        name => $user->{name},
        rating => $user->{rating},
        karma => $user->{karma}
    };
    return Local::Habr::FormatFactory->new($format)->process($obj);
}

sub commenters_by_post {
    my (%opts) = @_;
    my $post     = $opts{post};
    my $refresh  = $opts{refresh};
    my $format   = $opts{format};
    my $commenters = [
                   map  {{ name => $_->{name}, karma => $_->{karma}, rating => $_->{rating} }}
                   @{Local::Habr::User->get_commenters($post, $refresh)}
               ];
    return Local::Habr::FormatFactory->new($format)->process($commenters);
}

sub post_by_id {
    my (%opts) = @_;
    my $id       = $opts{id};
    my $format   = $opts{format};
    my $refresh  = $opts{refresh};
    my $post = Local::Habr::Post->get($id, $refresh, 1);
    if (not defined $post) {
        return undef;
    }
    my $topic = $post->{topic};
    my $obj = {
        author => $post->{author},
        topic  => $topic,
        rating => $post->{rating},
        views  => $post->{views},
        stars  => $post->{stars}
    };
    return Local::Habr::FormatFactory->new($format)->process($obj);
}

sub self_commentors {
    my (%opts) = @_;
    my $format   = $opts{format};
    my $commenters = [
                   map  {{ name => $_->{name}, karma => $_->{karma}, rating => $_->{rating} }}
                   @{Local::Habr::User->get_selfers()}
               ];
    return Local::Habr::FormatFactory->new($format)->process($commenters);
}

sub desert_posts {
    my (%opts) = @_;
    my $format   = $opts{format};
    my $n        = $opts{n};
    my $commenters = [
                   map  {{
                       author => $_->{author},
                       topic  => $_->{topic},
                       rating => $_->{rating},
                       views  => $_->{views},
                       stars  => $_->{stars}
                   }}
                   @{Local::Habr::Post->desert($n)}
               ];
    return Local::Habr::FormatFactory->new($format)->process($commenters);
}


our @EXPORT = qw(user_by_name user_by_post commenters_by_post post_by_id self_commentors desert_posts);


1;
