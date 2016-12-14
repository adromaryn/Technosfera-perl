package MusicLib::Controller::Track;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Model::Album;
use MusicLib::Model::Track;
use MusicLib::Helper::CurrentUser;
use MusicLib::Helper::Dupl;
use Mojo::Upload;

sub new_ {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
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
}

sub create {
  my $self = shift;
  my $album_id = $self->param('id');
  my $title = $self->param('title');
  my $format = $self->param('format');
  my $link = $self->param('link');

  my $current_user = current_user($self);
  my $album = MusicLib::Model::Album->read($album_id);
  my $user_name = $album->{user_name};
  if ($user_name eq $current_user) {
    my $result = MusicLib::Model::Track->create(album => $album_id, title => $title, format => $format, link => $link);
    if (not defined $result->{error}) {
      $self->flash({success => 'You add new track'});
      $self->redirect_to("/albums/id$album_id", status => 200);
    } elsif (is_dupl($result->{error})) {
      $self->flash({error => 'Track with this title already exists in this album'});
      $self->redirect_to("/albums/id$album_id", status => 400);
    } else {
      $self->flash({error => 'Something wrong'});
      $self->redirect_to("/albums/id$album_id", status => 400);
    }
  } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$album_id", status => 403);
  }
}

sub edit {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album = MusicLib::Model::Album->read($track->{album_id});
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      $self->render(track => $track, logined => 1);
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
    $self->redirect_to("/", status => 400);
  }
}

sub update {
  my $self = shift;
  my $id = $self->param('id');
  my $title = $self->param('title');
  my $format = $self->param('format');
  my $link = $self->param('link');

  my $validation = $self->validation;
  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album_id = $track->{album_id};
    my $album = MusicLib::Model::Album->read($album_id);
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      my $result = MusicLib::Model::Track->update(id     => $id,
                                                  title  => $title,
                                                  format => $format,
                                                  link   => $link);
      if (not defined $result->{error}) {
        $self->flash({success => 'Track edited'});
        $self->redirect_to("/albums/id$album_id", status => 200);
      } elsif (is_dupl($result->{error})) {
        $self->flash({error => 'Track with this title already exists in this album'});
        $self->redirect_to("/albums/id$album_id", status => 400);
      } else {
        $self->flash({error => 'Something wrong'});
        $self->redirect_to("/albums/id$album_id", status => 400);
      }
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
    $self->redirect_to("/", status => 400);
  }
}

sub destroy {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album_id = $track->{album_id};
    my $album = MusicLib::Model::Album->read($album_id);
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      my $result = MusicLib::Model::Track->delete($id);
      if (defined $result) {
        $self->flash({error => 'Something wrong'});
        $self->redirect_to("/albums/id$album_id", status => 500);
      } else {
        $self->flash({success => 'Track deleted'});
        $self->redirect_to("/albums/id$album_id", status => 200);
      }
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
    $self->redirect_to("/", status => 400);
  }
}

sub add_image {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album = MusicLib::Model::Album->read($track->{album_id});
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      $self->render(id => $id, logined => 1);
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
    $self->redirect_to("/", status => 400);
  }
}

sub post_image {
  my $self = shift;
  my $id = $self->param('id');
  my $image = $self->req->upload('image');

  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album_id = $track->{album_id};
    my $album = MusicLib::Model::Album->read($album_id);
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      if ($image->filename =~ /(jpg|png)$/) {
        $image->move_to("users/$id.$1");
        $self->redirect_to("/albums/id$album_id", status=>200);
      } else {
        $self->flash({error => 'Only jpg or png images'});
        $self->redirect_to("/tracks/id$id/image", status => 400);
      }
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
    $self->redirect_to("/", status => 400);
  }
}

sub delete_image {
  my $self = shift;
  my $id = $self->param('id');

  my $current_user = current_user($self);
  my $track = MusicLib::Model::Track->read($id);
  if (defined $track) {
    my $album_id = $track->{album_id};
    my $album = MusicLib::Model::Album->read($album_id);
    if (not defined $album) {
      $self->redirect_to("/", status => 500);
    } elsif ($album->{user_name} eq $current_user) {
      `rm -rf users/$id.*`;
      $self->redirect_to("/albums/id$album_id", status=>200);
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/albums/id$id", status => 403);
    }
  } else {
      $self->redirect_to("/", status => 400);
  }
}

1;
