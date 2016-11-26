package MusicLib::Controller::User;
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
use MusicLib::Helper::CurrentUser 'current_user';

sub new_ {
  my $self = shift;

  $self->render(logined => '');
}

sub create {
  my $self = shift;
  my $name = $self->param('name');
  my $password = $self->param('password');
  my $repeat = $self->param('repeat');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } elsif ($name !~ /^[a-z1-9_]+$/) {
    $self->flash({error => 'Name should include only lowercase latin characters, nums and _ and be non-empty'});
    $self->redirect_to('/users/new', status => 400);
  } elsif(length $password < 6) {
    $self->flash({error => 'Minimal pass length is 6 characters'});
    $self->redirect_to('/users/new', status => 400)
  } elsif ($password ne $repeat) {
    $self->flash({error => 'Passwords different'});
    $self->redirect_to('/users/new', status => 400);
  } else {
    my $cost = MusicLib::Secret->cost();
    my $salt = MusicLib::Secret->salt();
    my $bcrypt = Digest->new('Bcrypt');
    $bcrypt->cost($cost);
    $bcrypt->salt($salt);
    $bcrypt->add($password);
    my $digest = $bcrypt->b64digest;
    my $result = MusicLib::Model::User->create($name, $digest);
    if (not defined $result) {
      my $session_salt = my $salt = MusicLib::Secret->session_salt();
      my $token = Session::Token->new(length => 120)->get . Digest::MD5->new->add($name)->b64digest . $name;
      my $memd = MusicLib::Cache->get();
      $memd->set($token, $name);
      $self->session(expiration => 3600*24*10);
      $self->session({token => $token});
      $self->redirect_to("/");
    } elsif ($result == 1062) {
      $self->flash({error => "User already exists"});
      $self->redirect_to('/users/new', status => 400);
    } else {
      $self->flash({error => "Something wrong ;("});
      $self->redirect_to('/users/new', status => 500);
    }
  }
}

sub show {
  my $self = shift;
  my $name = $self->param('name');
  my $user = MusicLib::Model::User->read($name);
  if (not defined $user) {
    my $current_user = current_user($self);
    if ($current_user eq $name) {
      my $token = $self->session('token')||'';
      MusicLib::Cache->get()->delete($token);
      $self->redirect_to('/', status => 401)
    } else {
      $self->redirect_to('/', status => 404);
    }
  } else {
    $self->render(name => $user->{name}, logined => 1);
  }
}

sub me {
  my $self = shift;
  my $user = current_user($self);
  if (defined $user) {
    $self->redirect_to("/users/name/$user");
  } else {
    redirect_to('/login', status => 401)
  }
}

1;
