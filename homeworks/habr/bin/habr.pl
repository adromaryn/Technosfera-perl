#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Habr;
use feature 'say';
use DBI;
use Cache::Memcached::Fast;
use utf8;
use Getopt::Long;
use JSON::XS;

my $filename = "$FindBin::Bin/config.json";

my $config = decode_json do {
   open(my $json_fh, "<:encoding(UTF-8)", $filename)
      or die("Can't open \$filename\": $!\n");
   local $/;
   <$json_fh>
};

my $dbh = DBI->connect(
    @{$config->{db}}
);

my $memd = Cache::Memcached::Fast->new($config->{memd});

my $command = shift;

my $format = 'json';
my $refresh = 0;
my $name;
my $post;
my $id;
my $n;
GetOptions (
    "format=s" => \$format,
    "refresh"  => \$refresh,
    "name=s"   => \$name,
    "post=i"   => \$post,
    "id=i"     => \$id,
    'n=i'      => \$n
);

my $out;
if ($command eq "user") {
    if (defined $name) {
        $out = user_by_name(
            name => $name,
            format => $format,
            refresh => $refresh,
            db => $dbh,
            memd => $memd
        );
    } elsif ($post) {
        $out = user_by_post(
            post => $post,
            format => $format,
            refresh => $refresh,
            db => $dbh,
            memd => $memd
        );
    } else {
        die 'user [--name name | --post post_id]';
    }
} elsif($command eq 'commenters') {
    if (defined $post) {
        $out = commenters_by_post(
            post => $post,
            refresh => $refresh,
            format => $format,
            db => $dbh
        );
    } else {
        die 'commenters [--post post_id]';
    }
} elsif ($command eq 'post') {
    if (defined $id) {
        $out = post_by_id(
            id => $id,
            format => $format,
            refresh => $refresh,
            db => $dbh,
            memd => $memd
        );
    } else {
        die 'post [--id post_id]';
    }
} elsif ($command eq 'self_commentors') {
    $out = self_commentors(
        format => $format,
        db => $dbh
    );
} elsif ($command eq 'desert_posts') {
    if (defined $n) {
        $out = desert_posts(
            n => $n,
            format => $format,
            db => $dbh
        );
    } else {
        die 'desert_posts [--n n]';
    }
} else {
    die 'wrong command';
}

if (defined $out) {
    say $out;
} else {
    say 'not found';
}
