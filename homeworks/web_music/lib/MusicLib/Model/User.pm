package MusicLib::Model::User;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use Mouse;
use MusicLib::DB

has name   => (is => 'ro', isa => 'Str', required => 1);
has hash   => (is => 'ro', isa => 'Str', required => 1);

sub create {
  my $pkg = shift;
  my $name = shift;
  my $hash = shift;
  my $dbh = MusicLib::DB->get();
  my $sth = $dbh->prepare('INSERT INTO users (name, hash) VALUES (?, ?)');
  $sth->execute($name, $hash);
  if ( $sth->err ) {
    return $sth->err;
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

1;
