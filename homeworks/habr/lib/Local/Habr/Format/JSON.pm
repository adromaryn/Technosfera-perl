package Local::Habr::Format::JSON;

use strict;
use warnings;

use Mouse;
use JSON::XS;
use utf8;

extends 'Local::Habr::Format';

sub process {
    my ($self, $hash, @args) = @_;
    return encode_json $hash;
}

1;
