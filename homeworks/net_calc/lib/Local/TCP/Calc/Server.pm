package Local::TCP::Calc::Server;

use strict;
use warnings;
use feature 'say';
use Local::TCP::Calc;
use Local::TCP::Calc::Server::Queue;
use Local::TCP::Calc::Server::Worker;
use IO::Socket;
use IO::Socket qw( :addrinfo);
use POSIX ":sys_wait_h";
use JSON::XS qw(encode_json decode_json);

my $max_worker;
my $in_process = 0;

my $pids_master = {};
my $receiver_count = 0;
my $max_forks_per_task = 0;

$SIG{CHLD} = 'IGNORE';

sub start_server {
	my ($pkg, $port, %opts) = @_;
    my $max_queue_task = $opts{max_queue_task} // die "max_queue_task required";
	$max_worker = $opts{max_worker} // die "max_worker required";
	$max_forks_per_task = $opts{max_forks_per_task} // die "max_forks_per_task required";
	my $max_receiver    = $opts{max_receiver} // die "max_receiver required";
	# Инициализируем сервер my $server = IO::Socket::INET->new(...);
	my $server = IO::Socket::INET->new(
	    LocalPort => $port,
	    Type => SOCK_STREAM,
	    ReuseAddr => 1,
	    Listen => 10
	) or die "Couldn't be a tcp server on port $port : $@\n";
	my $q = Local::TCP::Calc::Server::Queue->new();
	$q->init($max_receiver);
	# Начинаем accept-тить подключения
	while (my $client = $server->accept()) {
		$client->autoflush(1);
        # Проверяем, что количество принимающих форков не вышло за пределы допустимого ($max_receiver)
    	# Если все нормально отвечаем клиенту TYPE_CONN_OK() в противном случае TYPE_CONN_ERR()
        if($receiver_count == $max_receiver) {
			my $data = {
						   header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_ERR(), 2),
						   message => "ok"
					   };
			my $res = encode_json $data;
            print $client $res."\n";
        } else {
            my $child = fork();
            if($child){
                close ($client);
                next;
            }
            if (defined $child){
                $receiver_count++;
                close($server);
                my $other = getpeername($client);
                my ($err, $host, $service) = getnameinfo($other);
                print "Client $host:$service $/";
				my $data = {
							   header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_OK(), 2),
							   message => "ok"
						   };
				my $res = encode_json $data;
                $client ->send($res."\n");
				while(<$client>) {
					# В каждом форке читаем сообщение от клиента, анализируем его тип (TYPE_START_WORK(), TYPE_CHECK_WORK())
					my %answer = %{decode_json $_};
					my ($type, $size) = @{Local::TCP::Calc->unpack_header($answer{header})};
					# Не забываем проверять количество прочитанных/записанных байт из/в сеть
					if ($size != length ($answer{message})) {
						my $error = "Wrong message length";
						my $data = {
									   header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_ERR(), length $error),
									   message => $error
								   };
					    my $res= encode_json $data;
		   		        $client ->send($res."\n");
					} else {

						if ($type == Local::TCP::Calc::TYPE_CHECK_WORK()) {
							print 555;
						} elsif($type == Local::TCP::Calc::TYPE_START_WORK()) {
							my $task = $answer{message};
							# Если необходимо добавляем задание в очередь (проверяем получилось или нет)
							my $queue_ok = $q->add($task);
							if ($queue_ok) {
							    my $data = {
							    	header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_OK(), 2),
								    message => 'ok'
							    };
							my $res= encode_json $data;
							$client ->send($res."\n");
							} else {
								my $error = "Queue overflow";
								my $data = {
									header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_ERR(), length $error),
									message => $error
								};
								my $res= encode_json $data;
					   		    $client ->send($res."\n");
							}
						} else {
							my $error = "Wrong request type";
							my $data = {
								header => Local::TCP::Calc->pack_header(Local::TCP::Calc::TYPE_CONN_ERR(), length $error),
								message => $error
							};
							my $res= encode_json $data;
				   		    $client ->send($res."\n");
						}
					}
				}
				close( $client );
                $receiver_count--;
                exit;
            } else { die "Can't fork: $!"; }
        }
	# Если пришли с проверкой статуса, получаем статус из очереди и отдаём клиенту
	# В случае если статус DONE или ERROR возвращаем на клиент содержимое файла с результатом выполнения
	# После того, как результат передан на клиент зачищаем файл с результатом
    }
}

sub check_queue_workers {
	my $self = shift;
	my $q = shift;
	# Функция в которой стартует обработчик задания
	# Должна следить за тем, что бы кол-во обработчиков не превышало мексимально разрешённого ($max_worker)
	# Но и простаивать обработчики не должны
	# my $worker = Local::TCP::Calc::Server::Worker->new(...);
	# $worker->start(...);
	# $q->to_done ...
}

1;
