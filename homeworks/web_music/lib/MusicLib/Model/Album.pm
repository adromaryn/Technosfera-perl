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
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO albums (user_name, title, band, year) VALUES (?, ?, ?, ?)');
  $sth->execute($opts{user}, $opts{title}, $opts{band}, $opts{year});
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
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('UPDATE albums SET title = ?, band = ?, year = ? WHERE id = ?');
  $sth->execute($opts{title}, $opts{band}, $opts{year}, $opts{user});
  if (my $err = $sth->err) {
    $dbh->rollback;
    return  $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

sub get_id {
  my $pkg = shift;
  my $title = shift;
  my $band = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE title = ? AND band = ?');
  $sth->execute($title, $band);
  my $album = $sth->fetchrow_hashref();
  if (defined $album) {
    return $album->{id};
  } else {
    return undef;
  }
}

1;
