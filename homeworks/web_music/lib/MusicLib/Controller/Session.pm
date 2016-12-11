package MusicLib::Controller::Session;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Digest;
use MusicLib::Secret;
use MusicLib::Model::User;
use MusicLib::Cache;
use Digest::MD5;
use Session::Token;
use MusicLib::Helper::CurrentUser;

sub new_ {
  my $self = shift;

  $self->render(logined => '');
}

sub create {
  my $self = shift;
  my $name = $self->param('name');
  my $password = $self->param('password');

  my $cost = MusicLib::Secret->cost();
  my $salt = MusicLib::Secret->salt();
  my $bcrypt = Digest->new('Bcrypt');
  $bcrypt->cost($cost);
  $bcrypt->salt($salt);
  $bcrypt->add($password);
  my $digest = $bcrypt->b64digest;

  my $user = MusicLib::Model::User->read($name);

  if (defined $user and $user->{hash} eq $digest) {
    my $token = Session::Token->new(length => 120)->get;
    my $memd = MusicLib::Cache->get();
    $memd->set($token, $user->{name});
    $self->session(expiration => 3600*24*10);
    $self->session({token => $token});
    $self->redirect_to("/");
  } else {
    $self->flash({error => 'Wrong pass or name'});
    $self->redirect_to("/login", status => 400);
  }
}

sub destroy {
  my $self = shift;
  my $token = $self->session('token')||'';
  MusicLib::Cache->get()->delete($token);
  $self->redirect_to("/login");
}

1;
