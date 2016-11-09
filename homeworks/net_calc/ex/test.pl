#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::TCP::Calc::Server;

my $server =  Local::TCP::Calc::Server -> start_server(
    "3000",
    max_queue_task => 5,
    max_worker => 3,
    max_forks_per_task => 3,
    max_receiver =>3
);
