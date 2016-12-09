package MusicLib::Controller::Table;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Model::Album;
use MusicLib::Model::Track;
use MusicLib::Helper::CurrentUser 'current_user';
use MusicLib::Helper::Table;
use Digest::MD5;

sub new_ {
  my $self = shift;
  $self->render(logined => 1);
}

sub create {
  my $self = shift;
  my $table = $self->param('table');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } else {
    my $lines = parse($table);
    my %albums_hash;
    my $user = current_user($self);
    if (defined $user) {
      for my $line (@$lines) {
        my ($album, $band) = ($line->{album}, $line->{band});
        if (not defined $albums_hash{$album}) {
          my $result = MusicLib::Model::Album->create($user, $album, $band, $line->{year});
          if (not defined $result or $result == 1062) {
            my $str = Digest::MD5->new->add($album)->b64digest . Digest::MD5->new->add($band)->b64digest;
            mkdir "public/$user/$str";
            my %band_hash = ($band, -1);
            $albums_hash{$album} = \%band_hash;
          }
        } elsif (not defined $albums_hash{$album}->{$band}) {
          my $result = MusicLib::Model::Album->create($user, $album, $band, $line->{year});
          if (not defined $result or $result == 1062) {
            my $str = Digest::MD5->new->add($album)->b64digest . Digest::MD5->new->add($band)->b64digest;
            mkdir "public/$user/$str";
            $albums_hash{$album}->{$band} = -1;
          }
        }
        if ($albums_hash{$album}->{$band} == -1) {
          my $id = MusicLib::Model::Album->get_id($album, $band);
          if (defined $id) {
            $albums_hash{$album}->{$band} = $id;
          }
        }
        if ($albums_hash{$album}->{$band} != -1) {
          my $result = MusicLib::Model::Track->create($albums_hash{$album}->{$band}, $line->{track}, $line->{format});
          if (not defined $result) {
            my $album_str = Digest::MD5->new->add($album)->b64digest . Digest::MD5->new->add($band)->b64digest;
            my $track_str = Digest::MD5->new->add($line->{track})->b64digest;
            mkdir "public/$user/$album_str/$track_str";
            $self->flash({success => 'You add new track'});
          }
        }
      }
    } else {
      $self->flash({error => 'Not authenticated'});
      $self->redirect_to("/login", status => 401);
    }
    $self->redirect_to('/');
    }
}

1;
