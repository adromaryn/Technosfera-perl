package MusicLib::Controller::Album;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Model::Album;
use MusicLib::Model::Track;
use MusicLib::Helper::CurrentUser 'current_user';
use Digest::MD5;

sub new_ {
  my $self = shift;
  $self->render(logined => 1);
}

sub create {
  my $self = shift;
  my $title = $self->param('title');
  my $band = $self->param('band');
  my $year = $self->param('year');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } elsif ($year !~ /^[\d]{4}$/) {
    $self->flash({error => 'Year: only 4 digits'});
    $self->redirect_to("/albums/new", status => 400);
  } else {
    my $current_user = current_user($self);
    if (defined $current_user) {
      my $result = MusicLib::Model::Album->create($current_user, $title, $band, $year);
      if (not defined $result) {
        my $str = Digest::MD5->new->add($title)->b64digest . Digest::MD5->new->add($band)->b64digest;
        mkdir "public/$current_user/$str";
        $self->redirect_to('/');
      } else {
        $self->redirect_to('/albums/new');
      }
    }
  }
}

sub show {
  my $self = shift;
  my $id = $self->param('id');
  my $album = MusicLib::Model::Album->read($id);
  my $current_user = current_user($self);
  if (not defined $album) {
    $self->redirect_to('/', status => 400);
  } elsif ($current_user eq $album->{user_name}) {
    my $tracks = MusicLib::Model::Track->all($id);
    if (defined $tracks) {
      my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
      $self->render(album => $album, logined => 1, owner => 1, tracks => $tracks, album_str => $album_str);
    } else {
      $self->redirect_to('/');
    }
  } else {
    my $tracks = MusicLib::Model::Track->all($id);
    if (defined $tracks) {
      my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
      $self->render(album => $album, logined => 1, owner => '', tracks => $tracks, album_str => $album_str);
    } else {
      $self->redirect_to('/');
    }
  }
}

sub edit {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  if (defined $current_user) {
    my $album = MusicLib::Model::Album->read($id);
    if (defined $album) {
      my $user = $album->{user_name};
      if ($user eq $current_user) {
        $self->render(album => $album, logined => 1);
      } else {
        $self->flash({error => 'Permissions denied'});
        $self->redirect_to("/albums/id$id", status => 403);
      }
    } else {
      $self->redirect_to("/", status => 400);
    }
  } else {
    $self->flash({error => 'Not authenticated'});
    $self->redirect_to("/login", status => 401);
  }
}

sub update {
  my $self = shift;
  my $id = $self->param('id');
  my $title = $self->param('title');
  my $band = $self->param('band');
  my $year = $self->param('year');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } elsif ($year !~ /^[\d]{4}$/) {
    $self->flash({error => 'Year: only 4 digits'});
    $self->redirect_to("/albums/id$id", status => 400);
  } else {
    my $current_user = current_user($self);
    if (defined $current_user) {
      my $album = MusicLib::Model::Album->read($id);
      if (defined $album) {
        my $user = $album->{user_name};
        if ($user eq $current_user) {
          my $result = MusicLib::Model::Album->update($id, $title, $band, $year);
          if (not defined $result) {
            my $dir = Digest::MD5->new->add($title)->b64digest . Digest::MD5->new->add($band)->b64digest;
            my $old = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
            if (-d "public/$current_user/$old") {
              rename "public/$current_user/$old", "public/$current_user/$dir";
            } elsif (-e "public/$current_user/$old") {
              `rm -rf ./public/$current_user/$old`;
              mkdir "public/$current_user/$dir";
            } else {
              mkdir "public/$current_user/$dir";
            }
            $self->flash({success => 'Album edited'});
            $self->redirect_to("/albums/id$id", status => 200);
          } else {
            $self->flash({error => 'Something wrong ;('});
            $self->redirect_to("/albums/id$id", status => 500);
          }
        } else {
          $self->flash({error => 'Permissions denied'});
          $self->redirect_to("/login", status => 403);
        }
      } else {
        $self->flash({error => 'Album not found'});
        $self->redirect_to("/", status => 400);
      }
    } else {
      $self->flash({error => 'Not authenticated'});
      $self->redirect_to("/login", status => 401);
    }
  }
}

1;
