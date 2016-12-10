package MusicLib::Cache;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use base 'Class::Singleton';
use Cache::Memcached::Fast;
use MusicLib::Config;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless { }, $pkg;

    $self->{ memd } = Cache::Memcached::Fast->new(MusicLib::Config->get()->{memd});

    return $self;
}

sub get { $_[0]->instance()->{memd}; }

1;
