package MusicLib::Secret;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use base 'Class::Singleton';
use FindBin;
use JSON::XS;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless { }, $pkg;
    my $filename = "$FindBin::Bin/../conf/config.json";

    my $config = decode_json do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open \$filename\": $!\n");
       local $/;
       <$json_fh>
    };

    $self->{ cost } = $config->{secret}->{cost};
    $self->{ salt } = $config->{secret}->{salt};
    $self->{ session_salt } = $config->{secret}->{session_salt};

    return $self;
}

sub salt { $_[0]->instance()->{salt}; }
sub cost { $_[0]->instance()->{cost}; }
sub session_salt { $_[0]->instance()->{session_salt}; }

1;
