package MusicLib::Controller::Track;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use utf8;
use feature ':5.10';

use MusicLib::Model::Album;
use MusicLib::Model::Track;
use MusicLib::Helper::CurrentUser 'current_user';
use Digest::MD5;
use Mojo::Upload;

sub new_ {
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

sub create {
  my $self = shift;
  my $album_id = $self->param('id');
  my $title = $self->param('title');
  my $format = $self->param('format');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } else {
    my $current_user = current_user($self);
    if (defined $current_user) {
      my $album = MusicLib::Model::Album->read($album_id);
      my $user_name = $album->{user_name};
      if ($user_name eq $current_user) {
        my $result = MusicLib::Model::Track->create($album_id, $title, $format);
        if (not defined $result) {
          my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
          my $track_str = Digest::MD5->new->add($title)->b64digest;
          mkdir "public/$current_user/$album_str/$track_str";
          $self->flash({success => 'You add new track'});
          $self->redirect_to("/albums/id$album_id", status => 200);
        } elsif ($result == 1062) {
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
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/login", status => 401);
    }
  }
}

sub edit {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  if (defined $current_user) {
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
  } else {
    $self->flash({error => 'Not authenticated'});
    $self->redirect_to("/login", status => 401);
  }
}

sub update {
  my $self = shift;
  my $id = $self->param('id');
  my $title = $self->param('title');
  my $format = $self->param('format');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } else {
    my $current_user = current_user($self);
    if (defined $current_user) {
      my $track = MusicLib::Model::Track->read($id);
      if (defined $track) {
        my $album_id = $track->{album_id};
        my $album = MusicLib::Model::Album->read($album_id);
        if (not defined $album) {
          $self->redirect_to("/", status => 500);
        } elsif ($album->{user_name} eq $current_user) {
          my $old_track_str = Digest::MD5->new->add($track->{title})->b64digest;
          my $result = MusicLib::Model::Track->update($id, $title, $format);
          if (not defined $result) {
            my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
            my $track_str = Digest::MD5->new->add($title)->b64digest;
            if (-d "public/$current_user/$album_str/$old_track_str") {
              rename "public/$current_user/$album_str/$old_track_str", "public/$current_user/$album_str/$track_str";
            } elsif (-e "public/$current_user/$album_str/$old_track_str") {
              `rm -rf "public/$current_user/$album_str/$old_track_str"`;
              mkdir "public/$current_user/$album_str/$track_str";
            } else {
              mkdir "public/$current_user/$album_str/$track_str";
            }
            $self->flash({success => 'Track edited'});
            $self->redirect_to("/albums/id$album_id", status => 200);
          } elsif ($result == 1062) {
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
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/login", status => 401);
    }
  }
}

sub destroy {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  if (defined $current_user) {
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
          my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
          my $track_str = Digest::MD5->new->add($track->{title})->b64digest;
          `rm -rf "public/$current_user/$album_str/$track_str"`;
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
  } else {
    $self->flash({error => 'Not authenticated'});
    $self->redirect_to("/login", status => 401);
  }
}

sub add_image {
  my $self = shift;
  my $id = $self->param('id');
  my $current_user = current_user($self);
  if (defined $current_user) {
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
  } else {
    $self->flash({error => 'Not authenticated'});
    $self->redirect_to("/login", status => 401);
  }
}

sub post_image {
  my $self = shift;
  my $id = $self->param('id');
  my $image = $self->req->upload('image');

  my $validation = $self->validation;
  if ($validation->csrf_protect->has_error('csrf_token')) {
    $self->flash({error => 'Bad CSRF token!'});
    $self->redirect_to("/login", status => 403);
  } else {
    my $current_user = current_user($self);
    if (defined $current_user) {
      my $track = MusicLib::Model::Track->read($id);
      if (defined $track) {
        my $album_id = $track->{album_id};
        my $album = MusicLib::Model::Album->read($album_id);
        if (not defined $album) {
          $self->redirect_to("/", status => 500);
        } elsif ($album->{user_name} eq $current_user) {
          if ($image->filename =~ /(jpg)|(png)$/) {
            my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
            my $track_str = Digest::MD5->new->add($track->{title})->b64digest;
            `rm -rf "public/$current_user/$album_str/$track_str/img"`;
            $image->move_to("public/$current_user/$album_str/$track_str/img");
            $self->redirect_to("/albums/id$album_id", status=>200);
          } else {
            $self->flash({error => 'Only jpg or bmp images'});
            $self->redirect_to("/tracks/id$id/image", status => 400);
          }
        } else {
          $self->flash({error => 'Permissions denied'});
          $self->redirect_to("/albums/id$id", status => 403);
        }
      } else {
        $self->redirect_to("/", status => 400);
      }
    } else {
      $self->flash({error => 'Permissions denied'});
      $self->redirect_to("/login", status => 401);
    }
  }
}

sub delete_image {
  my $self = shift;
  my $id = $self->param('id');

  my $current_user = current_user($self);
  if (defined $current_user) {
    my $track = MusicLib::Model::Track->read($id);
    if (defined $track) {
      my $album_id = $track->{album_id};
      my $album = MusicLib::Model::Album->read($album_id);
      if (not defined $album) {
        $self->redirect_to("/", status => 500);
      } elsif ($album->{user_name} eq $current_user) {
        my $album_str = Digest::MD5->new->add($album->{title})->b64digest . Digest::MD5->new->add($album->{band})->b64digest;
        my $track_str = Digest::MD5->new->add($track->{title})->b64digest;
        `rm -rf "public/$current_user/$album_str/$track_str/img"`;
        $self->redirect_to("/albums/id$album_id", status=>200);
      } else {
        $self->flash({error => 'Permissions denied'});
        $self->redirect_to("/albums/id$id", status => 403);
      }
    } else {
        $self->redirect_to("/", status => 400);
    }
  } else {
    $self->flash({error => 'Permissions denied'});
    $self->redirect_to("/login", status => 401);
  }
}

1;
