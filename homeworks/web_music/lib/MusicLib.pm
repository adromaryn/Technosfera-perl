package MusicLib;
use Mojo::Base 'Mojolicious';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Cache;
use MusicLib::Helper::CurrentUser;
use DDP;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin('CSRFProtect');

  # Router
  my $r = $self->routes;

  # Authenticate based on name parameter
  my $auth = $r->under( sub {
    my $c = shift;
    my $name = current_user($c);
    $c->stash(logged => 1);
    # Authenticated
    return 1 if defined $name;

    # Not authenticated

    $c->flash({error => 'Not authenticated'});
    $c->redirect_to("/login", status => 401);
    return undef;
  });

  my $unlogged = $r->under( sub {
    my $c = shift;
    $c->stash(logged => '');
    return 1;
  });

  $unlogged->get('/users/new')->to('user#new_');
  $unlogged->post('/users')->to('user#create');

  $unlogged->get('/login')->to('session#new_');
  $unlogged->post('/login')->to('session#create');
  $unlogged->post('/logout')->to('session#destroy');

  $auth->get('/users/name/:name')->to('user#show');
  $auth->get('/')->to('user#me');
  $auth->get('/users')->to('user#index');
  $auth->post('/users/delete')->to('user#destroy');

  $auth->get('/albums/new')->to('album#new_');
  $auth->post('/albums')->to('album#create');
  $auth->get('/albums/id:id')->to('album#show');
  $auth->get('/albums/id:id/edit')->to('album#edit');
  $auth->post('/albums/id:id/edit')->to('album#update');

  $auth->get('/albums/id:id/tracks/new')->to('track#new_');
  $auth->post('/albums/id:id/tracks')->to('track#create');
  $auth->get('/tracks/id:id/edit')->to('track#edit');
  $auth->post('/tracks/id:id/edit')->to('track#update');
  $auth->get('/tracks/id:id/delete')->to('track#destroy');
  $auth->get('/tracks/id:id/image')->to('track#add_image');
  $auth->post('/tracks/id:id/image')->to('track#post_image');
  $auth->get('/tracks/id:id/image/delete')->to('track#delete_image');

  $auth->get('/table')->to('table#new_');
  $auth->post('/table')->to('table#create');
}

1;
