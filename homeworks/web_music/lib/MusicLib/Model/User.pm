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
  eval {$sth->execute($name, $hash);};
  if ($@) {
    return $@->{message};
  } else {
    return undef;
  }
}

sub read {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM users WHERE name = ?');
  eval {$sth->execute($name);};
  if ($@) {
    return undef;
  } else {
    my $user = $sth->fetchrow_hashref();
    return MusicLib::Model::User->new($user);
  }
}

sub delete {
  my $pkg = shift;
  my $name = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('DELETE FROM users WHERE name = ?');
  eval {$sth->execute($name);};
  if ($@) {
    return $@->{message};
  } else {
    return undef;
  }
}

sub all {
  my $pkg = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('SELECT * FROM users');
  eval {$sth->execute();};
  if ($@) {
    return undef;
  } else {
    my $users = $sth->fetchall_arrayref({});
    return $users;
  }
}

1;
