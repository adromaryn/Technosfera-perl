package MusicLib::Secret;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use base 'Class::Singleton';
use FindBin;
use JSON::XS;
use MusicLib::Config;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless { }, $pkg;

    my $config = MusicLib::Config->get();

    $self->{ cost } = $config->{secret}->{cost};
    $self->{ salt } = $config->{secret}->{salt};
    $self->{ session_salt } = $config->{secret}->{session_salt};

    return $self;
}

sub salt { $_[0]->instance()->{salt}; }
sub cost { $_[0]->instance()->{cost}; }
sub session_salt { $_[0]->instance()->{session_salt}; }

1;
