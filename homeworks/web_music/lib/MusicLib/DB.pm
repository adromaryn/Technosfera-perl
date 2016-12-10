package MusicLib::DB;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use base 'Class::Singleton';
use DBI;
use MusicLib::Config;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless {}, $pkg;

    $self->{ DB } = DBI->connect(
        @{MusicLib::Config->get()->{db}}
    ) or die "Cannot connect to database: $DBI::errstr";

    return $self;
}

sub get { $_[0]->instance()->{DB}; }

1;
