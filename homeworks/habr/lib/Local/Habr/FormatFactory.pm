package Local::Habr::FormatFactory;

use strict;
use warnings;
use Mouse;
use utf8;
use Local::Habr::Format::JSON;
use Local::Habr::Format::XML;

sub new {
    my ($pkg, $format, @args) = @_;
    die "Unknown format" unless grep { lc($format) eq $_ } qw/json xml/;
    my $class = "Local::Habr::Format::".uc($format);
    return $class->new(@args);
}

1;
