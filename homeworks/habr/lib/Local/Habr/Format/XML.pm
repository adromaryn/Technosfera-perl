package Local::Habr::Format::XML;

use strict;
use warnings;

use Mouse;
use XML::Simple qw(:strict);
use utf8;

extends 'Local::Habr::Format';

sub process {
    my ($self, $hash, @args) = @_;
    my $xs = XML::Simple->new();
    return $xs->XMLout($hash);
}

1;
