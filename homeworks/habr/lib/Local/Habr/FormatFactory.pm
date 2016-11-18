package Local::Habr::FormatFactory;

use strict;
use warnings;

use Mouse;
use JSON::XS;
use XML::Simple qw(:strict);
use utf8;
use feature 'say';

has format  => (is => 'ro', isa => 'Str', required => 1);

sub process {
    my ($self,$obj) = @_;

    if ($self->{format} eq 'json') {
        return encode_json $obj;
    } elsif ($self->{format} eq 'xml') {
        my $xs = XML::Simple->new();
        return $xs->XMLout($obj);
    } else {
        die 'only json or xml output';
    }
}

1;
