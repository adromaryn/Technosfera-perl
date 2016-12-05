package MusicLib::Controller::Album;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Model::Album;
use MusicLib::Cache;
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
        say (not defined $result);
        my $str = Digest::MD5->new->add($title)->b64digest;
        mkdir "public/$current_user/$str";
        $self->redirect_to('/');
      } else {
        $self->redirect_to('/albums/new');
      }
    }
  }
}

1;
