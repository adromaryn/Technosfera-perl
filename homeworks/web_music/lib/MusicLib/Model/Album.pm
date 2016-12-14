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
  eval {$sth->execute($opts{user}, $opts{title}, $opts{band}, $opts{year});};
  if ($@) {
    return $@->{message};
  } else {
    return undef;
  }
}

sub all {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE user_name = ?');
  eval {$sth->execute($name);};
  if ($@) {
    return undef;
  } else {
    my $albums = $sth->fetchall_arrayref({});
    return $albums;
  }
}

sub read {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE id = ?');
  eval {$sth->execute($id);};
  if ($@) {
    return undef;
  } else {
    my $album = $sth->fetchrow_hashref();
    return MusicLib::Model::Album->new($album);
  }
}

sub update {
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('UPDATE albums SET title = ?, band = ?, year = ? WHERE id = ?');
  eval {$sth->execute($opts{title}, $opts{band}, $opts{year}, $opts{user});};
  if ($@) {
    return $@->{message};
  } else {
    return undef;
  }
}

sub get_id {
  my $pkg = shift;
  my $title = shift;
  my $band = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM albums WHERE title = ? AND band = ?');
  eval {$sth->execute($title, $band);};
  if ($@) {
    return undef;
  } else {
    my $album = $sth->fetchrow_hashref();
    return $album->{id};
  }
}

1;
