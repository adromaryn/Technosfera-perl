#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::TCP::Calc::Client;

my $server =  Local::TCP::Calc::Client -> set_connect(
    'localhost',
    '3000'
);

say Local::TCP::Calc::Client -> do_request($server, 1, "message");
#say Local::TCP::Calc::Client -> do_request($server, 1, "message");
