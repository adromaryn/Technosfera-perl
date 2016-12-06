package MusicLib::Model::Album;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Mouse;
use MusicLib::DB;

has id         => (is => 'ro', isa => 'Int', required => 1);
has user_name    => (is => 'ro', isa => 'Str', required => 1);
has title      => (is => 'ro', isa => 'Str', required => 1);
has band       => (is => 'ro', isa => 'Str', required => 1);
has year       => (is => 'ro', isa => 'Int', required => 1);

sub create {
  my $pkg = shift;
  my $user = shift;
  my $title = shift;
  my $band = shift;
  my $year = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO albums (user_name, title, band, year) VALUES (?, ?, ?, ?)');
  $sth->execute($user, $title, $band, $year);
  if (my $err = $sth->err) {
    $dbh->rollback;
    return  $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

sub all {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE user_name = ?');
  $sth->execute($name);
  my $albums = $sth->fetchall_arrayref({});
  if ($sth->err) {
    return undef;
  } else {
    return $albums;
  }
}

sub read {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE id = ?');
  $sth->execute($id);
  my $album = $sth->fetchrow_hashref();
  if (defined $album) {
    return MusicLib::Model::Album->new($album);
  } else {
    return undef;
  }
}

sub update {
  my $pkg = shift;
  my $id = shift;
  my $title = shift;
  my $band = shift;
  my $year = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('UPDATE albums SET title = ?, band = ?, year = ? WHERE id = ?');
  $sth->execute($title, $band, $year, $id);
  if (my $err = $sth->err) {
    $dbh->rollback;
    return  $err;
  } else {
    $dbh->commit;
    return undef;
  }
}



1;