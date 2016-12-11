package MusicLib::Model::Track;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Mouse;
use MusicLib::DB;

has id           => (is => 'ro', isa => 'Int', required => 1);
has album_id     => (is => 'ro', isa => 'Int', required => 1);
has title        => (is => 'ro', isa => 'Str', required => 1);
has format       => (is => 'ro', isa => 'Str', required => 1);
has link         => (is => 'ro', isa => 'Str', required => 1);

sub create {
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO tracks (album_id, title, format, link) VALUES (?, ?, ?, ?)');
  $sth->execute($opts{album}, $opts{title}, $opts{format}, $opts{link});
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
  my $album_id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM tracks WHERE album_id = ?');
  $sth->execute($album_id);
  my $tracks = $sth->fetchall_arrayref({});
  if ($sth->err) {
    return undef;
  } else {
    return $tracks;
  }
}

sub read {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM tracks WHERE id = ?');
  $sth->execute($id);
  my $track = $sth->fetchrow_hashref();
  if (defined $track) {
    return MusicLib::Model::Track->new($track);
  } else {
    return undef;
  }
}

sub update {
  my ($pkg, %opts) = @_;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('UPDATE tracks SET title = ?, format = ?, link = ? WHERE id = ?');
  $sth->execute($opts{title}, $opts{format}, $opts{link}, $opts{id});
  if (my $err = $sth->err) {
    $dbh->rollback;
    return  $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

sub delete {
  my $pkg = shift;
  my $id = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('DELETE FROM tracks WHERE id = ?');
  $sth->execute($id);
  if (my $err = $sth->err) {
    $dbh->rollback;
    return $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

1;
