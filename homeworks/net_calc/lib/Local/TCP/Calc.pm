package Local::TCP::Calc;

use strict;
use warnings;
use utf8;
use feature ':5.10';
use Exporter 'import';
use IO::Compress::Gzip qw(gzip $GzipError) ;

sub TYPE_START_WORK {1}
sub TYPE_CHECK_WORK {2}
sub TYPE_CONN_ERR   {3}
sub TYPE_CONN_OK    {4}

sub STATUS_NEW   {1}
sub STATUS_WORK  {2}
sub STATUS_DONE  {3}
sub STATUS_ERROR {4}

sub pack_header {
	my $pkg = shift;
	my $type = shift;
	my $size = shift;
	return $type." ".$size;
}

sub unpack_header {
	my $pkg = shift;
	my $header = shift;
	my @res = split " ", $header;
	return \@res;
}

sub pack_message {
	my $pkg = shift;
	my $messages = shift;
}

sub unpack_message {
	my $pkg = shift;
	my $message = shift;
}

our @EXPORT = qw(TYPE_CONN_ERR TYPE_CONN_OK TYPE_START_WORK TYPE_CHECK_WORK
                 STATUS_NEW STATUS_WORK STATUS_DONE STATUS_ERROR
								 pack_header unpack_header pack_message unpack_message);

1;
