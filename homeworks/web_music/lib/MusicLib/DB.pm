package MusicLib::DB;

use strict;
use warnings;
use utf8;
use feature ':5.10';

use base 'Class::Singleton';
use FindBin;
use JSON::XS 'decode_json';
use DBI;

sub _new_instance {
    my $pkg = shift;
    my $self  = bless {}, $pkg;
    my $filename = "$FindBin::Bin/../conf/config.json";

    my $config = decode_json do {
       open(my $json_fh, "<:encoding(UTF-8)", $filename)
          or die("Can't open \$filename\": $!\n");
       local $/;
       <$json_fh>
    };

    $self->{ DB } = DBI->connect(
        @{$config->{db}}
    ) or die "Cannot connect to database: $DBI::errstr";

    return $self;
}

sub get { $_[0]->instance()->{DB}; }

1;
