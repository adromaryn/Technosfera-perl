package Local::Habr::Cache;

use strict;
use warnings;

use base 'Class::Singleton';
use FindBin;
use JSON::XS;
use Cache::Memcached::Fast;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless { }, $pkg;
    my $filename = "$FindBin::Bin/config.json";

    my $config = decode_json do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open \$filename\": $!\n");
       local $/;
       <$json_fh>
    };

    $self->{ memd } = Cache::Memcached::Fast->new($config->{memd});

    return $self;
}

1;
