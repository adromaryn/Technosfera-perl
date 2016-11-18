package Local::Habr::DB;

use strict;
use warnings;

use base 'Class::Singleton';
use FindBin;
use JSON::XS 'decode_json';
use DBI;

sub instance {
    my $pkg = shift;
    my $self  = bless {}, $pkg;
    my $filename = "$FindBin::Bin/config.json";

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

1;
