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
use MusicLib::Helper::Dupl;

sub new_ {
  my $self = shift;
  $self->render(logined => 1);
}

sub create {
  my $self = shift;
  my $table = $self->param('table');

  my $lines = parse($table);
  my %albums_hash;
  my $user = current_user($self);
  for my $line (@$lines) {
    my ($album, $band) = ($line->{album}, $line->{band});
    if (not defined $albums_hash{$album}) {
      my $result = MusicLib::Model::Album->create(user => $user, title => $album, band => $band, year => $line->{year});
      if (not defined $result->{error} or is_dupl($result->{error})) {
        my %band_hash = ($band, -1);
        $albums_hash{$album} = \%band_hash;
      }
    } elsif (not defined $albums_hash{$album}->{$band}) {
      my $result = MusicLib::Model::Album->create(user => $user, title => $album, band => $band, year => $line->{year});
      if (not defined $result->{error} or is_dupl($result->{error})) {
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
      my $result = MusicLib::Model::Track->create(album  => $albums_hash{$album}->{$band},
                                                  title  => $line->{track},
                                                  format => $line->{format},
                                                  link   => '');
      if (not defined $result->{error}) {
        $self->flash({success => 'You add new track'});
      }
    }
  }
  $self->redirect_to('/');
}

1;
