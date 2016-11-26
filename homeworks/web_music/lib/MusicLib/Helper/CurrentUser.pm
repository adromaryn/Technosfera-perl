package MusicLib::Helper::CurrentUser;

use strict;
use warnings;
use utf8;
use feature ':5.10';
use Exporter 'import';

sub current_user {
  my $c = shift;
  my $token = $c->session('token')||'';
  return MusicLib::Cache->get()->get($token);
}

our @EXPORT = qw(current_user);

1;
