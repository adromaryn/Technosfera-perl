package MusicLib::Model::User;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Mouse;
use MusicLib::DB;

has name   => (is => 'ro', isa => 'Str', required => 1);
has hash   => (is => 'ro', isa => 'Str', required => 1);

sub create {
  my $pkg = shift;
  my $name = shift;
  my $hash = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO users (name, hash) VALUES (?, ?)');
  $sth->execute($name, $hash);
  if (my $err = $sth->err) {
    $dbh->rollback;
    return $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

sub read {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM users WHERE name = ?');
  $sth->execute($name);
  my $user = $sth->fetchrow_hashref();
  if (defined $user) {
    return MusicLib::Model::User->new($user);
  } else {
    return undef;
  }
}

sub delete {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth1 = $dbh->prepare('DELETE FROM users WHERE name = ?');
  my $sth2 = $dbh->prepare('DELETE FROM tracks WHERE album_id IN (SELECT id FROM albums WHERE user_name = ?)');
  my $sth3 = $dbh->prepare('DELETE FROM albums WHERE user_name = ?');
  $sth1->execute($name);
  $sth2->execute($name);
  $sth3->execute($name);
  if (my $err = $sth1->err || $sth2->err || $sth3->err) {
    $dbh->rollback;
    return $err;
  } else {
    $dbh->commit;
    return undef;
  }
}

sub all {
  my $pkg = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM users');
  $sth->execute();
  my $users = $sth->fetchall_arrayref({});
  if ($sth->err) {
    return undef;
  } else {
    return $users;
  }
}

1;
