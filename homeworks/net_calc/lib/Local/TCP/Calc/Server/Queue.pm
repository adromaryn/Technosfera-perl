package Local::TCP::Calc::Server::Queue;

use strict;
use warnings;
no warnings 'experimental';

use Mouse;
use Local::TCP::Calc;
use Fcntl ':flock';

has f_handle       => (is => 'rw', isa => 'FileHandle');
has queue_filename => (is => 'ro', isa => 'Str', default => '/tmp/local_queue.log');
has max_task       => (is => 'rw', isa => 'Int', default => 0);

sub init {
	my $self = shift;
	my $max_task = shift;
	# Подготавливаем очередь к первому использованию если это необходимо
	$self->{max_task} = $max_task;
}

sub open {
	my $self = shift;
	my $open_type = shift;
	# Открываем файл с очередью, не забываем про локи, возвращаем содержимое (перловая структура)
	CORE::open(my $fh, 'r', $self->{queue_filename});
	flock($fh, LOCK_EX) or die "can't flock: $!";
	my @lines = <$fh>;
	CORE::close($fh);
	my %struct = map {
		(split ' ', $_)[0] => {
			task   => (split ' ', $_)[1],
			status => (split ' ', $_)[2],
			result => (split ' ', $_)[3]
		}
	} @lines;
	return \%struct;
}

sub close {
	my $self = shift;
	my $struct = shift;
	# Перезаписываем файл с данными очереди (если требуется), снимаем лок, закрываем файл.
	my @lines = map {
		$_ . ' ' . $struct->{$_}->{task} . ' ' . $struct->{$_}->{status} . ' ' . $struct->{$_}->{result}
	} (keys %$struct);
	CORE::open(my $fh, 'w', $self->{queue_filename});
	print $fh join("\n", @lines);
	flock($fh, LOCK_UN) or die "can't flock: $!";
	CORE::close($fh);
}

sub to_done {
	my $self = shift;
	my $task_id = shift;
	my $file_name = shift;
	#...
	# Переводим задание в статус DONE, сохраняем имя файла с результатом работы
}

sub get_status {
	my $self = shift;
	my $id = shift;
	#...
	# Возвращаем статус задания по id, и в случае DONE или ERROR имя файла с результатом
}

sub delete {
	my $self = shift;
	my $id = shift;
	my $status = shift;
	...
	# Удаляем задание из очереди в соответствующем статусе
}

sub get {
	my $self = shift;
	...
	# Возвращаем задание, которое необходимо выполнить (id, tasks)
}

sub add {
	my $self = shift;
	my $new_work = shift;
	# Добавляем новое задание с проверкой, что очередь не переполнилась
	my $struct = $self->open(1);
	my @free = keys %{{
		map { $_ => undef }
		grep {
			not defined $struct->{$_}
		}
		(1..$self->{max_task})
	}};
	if (@free) {
		my $index = shift @free;
		$struct->{$index} = {task => $new_work, status => Local::TCP::Calc->STATUS_NEW() , result => 0};
		$self->close($struct);
	}
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
