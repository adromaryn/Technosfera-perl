package MusicLib;
use Mojo::Base 'Mojolicious';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Cache;
use MusicLib::Helper::CurrentUser;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Router
  my $r = $self->routes;

  $r->get('/users/new')->to('user#new_');
  $r->post('/users')->to('user#create');

  $r->get('/login')->to('session#new_');
  $r->post('/login')->to('session#create');
  $r->post('/logout')->to('session#destroy');

  # Authenticate based on name parameter
  my $auth = $r->under( sub {
    my $c = shift;
    my $name = current_user($c);
    # Authenticated
    return 1 if defined $name;

    # Not authenticated
    $c->redirect_to('/login');
    return undef;
  });

  $auth->get('/users/name/:name')->to('user#show');
  $auth->get('/')->to('user#me');
  $auth->get('/users')->to('user#index');
  $auth->post('/users/delete')->to('user#destroy');

  $auth->get('/albums/new')->to('album#new_');
  $auth->post('/albums')->to('album#create');
  $auth->get('/albums/id:id')->to('album#show');
  $auth->get('/albums/id:id/edit')->to('album#edit');
  $auth->post('/albums/id:id/edit')->to('album#update');
}

1;
