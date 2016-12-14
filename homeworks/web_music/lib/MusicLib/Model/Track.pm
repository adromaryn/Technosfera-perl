package MusicLib::Model::Track;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Mouse;
use MusicLib::DB;
use DDP;

has id           => (is => 'ro', isa => 'Int', required => 1);
has album_id     => (is => 'ro', isa => 'Int', required => 1);
has title        => (is => 'ro', isa => 'Str', required => 1);
has format       => (is => 'ro', isa => 'Str', required => 1);
has link         => (is => 'ro', isa => 'Str', required => 1);

sub create {
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO tracks (album_id, title, format, link) VALUES (?, ?, ?, ?)');
  eval {$sth->execute($opts{album}, $opts{title}, $opts{format}, $opts{link});};
  if ($@) {
    return {error => $@->{message}};
  } else {
    return {id => $sth->{mysql_insertid}};
  }
}

sub all {
  my $pkg = shift;
  my $album_id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM tracks WHERE album_id = ?');
  eval {$sth->execute($album_id);};
  if ($@) {
    return undef;
  } else {
    my $tracks = $sth->fetchall_arrayref({});
    return $tracks;
  }
}

sub read {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM tracks WHERE id = ?');
  eval {$sth->execute($id);};
  if ($@) {
    return undef;
  } else {
    my $track = $sth->fetchrow_hashref();
    return MusicLib::Model::Track->new($track);
  }
}

sub update {
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('UPDATE tracks SET title = ?, format = ?, link = ? WHERE id = ?');
  eval {$sth->execute($opts{title}, $opts{format}, $opts{link}, $opts{id});};
  if ($@) {
    return {error => $@->{message}};
  } else {
    return {id => $sth->{mysql_insertid}};
  }
}

sub delete {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('DELETE FROM tracks WHERE id = ?');
  eval {$sth->execute($id);};
  if ($@) {
    return $@->{message};
  } else {
    return undef;
  }
}

1;
