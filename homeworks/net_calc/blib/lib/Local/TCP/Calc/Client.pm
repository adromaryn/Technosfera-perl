package Local::TCP::Calc::Client;

use strict;
use warnings;
use feature 'say';
use IO::Socket;
use Local::TCP::Calc;
use JSON::XS qw(encode_json decode_json);

sub set_connect {
	my $pkg = shift;
	my $ip = shift;
	my $port = shift;
	my $server = IO::Socket::INET->new(
	    PeerAddr => $ip,
		PeerPort => $port,
		Proto => "tcp",
		Type => SOCK_STREAM)
	or die "Can't connect to $ip:$port";
	$server->autoflush(1);
	my %answer = %{decode_json <$server>};
	# read header before read message
	my ($type, $size) = @{Local::TCP::Calc->unpack_header($answer{header})};
	# check on Local::TCP::Calc::TYPE_CONN_ERR();
	if ($type == Local::TCP::Calc -> TYPE_CONN_OK()){
		if ($size != length ($answer{message})) {
			die "header == $size, but message length == ". length $answer{message};
		}
	} else {
		die "Connection error";
	}
	return $server;
}

sub do_request {
	my $pkg = shift;
	my $server = shift;
	my $type = shift;
	my $message = shift;

	my $header = Local::TCP::Calc->pack_header($type, length($message));
	my $data = {
		header => $header,
		message => $message
	};
	my $req = encode_json($data) . "\n";

	print $server $req;
	my $answer = <$server>;
	my %res = %{decode_json $answer};
	($type, my $size) = @{Local::TCP::Calc->unpack_header($res{header})};
	# Проверить, что записанное/прочитанное количество байт равно длине сообщения/заголовка
	# Принимаем и возвращаем перловые структуры

	return $answer;
}

1;
