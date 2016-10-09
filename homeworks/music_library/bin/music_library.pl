#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
	push @INC, './lib';
}
no warnings 'experimental';

use Local::MusicLibrary;

my $data = mus_input();
mus_table(@$data);
