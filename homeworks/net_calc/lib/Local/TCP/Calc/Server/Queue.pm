package Local::TCP::Calc::Server::Queue;

use strict;
use warnings;
use DDP;
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
	CORE::open(my $fh, '>', $self->{queue_filename});
	CORE::close($fh);
}

sub open {
	my $self = shift;
	my $open_type = shift;
	# Открываем файл с очередью, не забываем про локи, возвращаем содержимое (перловая структура)
	CORE::open($self->{f_handle}, '<', $self->{queue_filename}) or die "Can't open < ". $self->{queue_filename}.": $!";
	my $fh = $self->{f_handle};
	flock($fh, LOCK_EX) or die "can't flock: $!";
	my @lines = <$fh>;
	CORE::close($self->{f_handle});
	for my $line (@lines) {
		chomp $line;
	}
	my %struct = map {
		(split '_', $_, 4)[0] => {
			task   => (split '_', $_)[3],
			status => (split '_', $_)[1],
			result => (split '_', $_)[2]
		}
	} @lines;
	return \%struct;
}

sub close {
	my $self = shift;
	my $struct = shift;
	# Перезаписываем файл с данными очереди (если требуется), снимаем лок, закрываем файл.
	my @lines = map {
		$_ . '_' . $struct->{$_}->{status} . '_' . $struct->{$_}->{result} . '_' . $struct->{$_}->{task}
	} (keys %$struct);
	CORE::open($self->{f_handle}, '>', $self->{queue_filename}) or die "Can't open < ". $self->{queue_filename}.": $!";
	my $fh = $self->{f_handle};
	print $fh join("\n", @lines);
	flock($fh, LOCK_UN) or die "can't flock: $!";
	CORE::close($self->{f_handle});
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
	my $struct = $self->open(1);
	if (defined $struct->{$id}) {
		# Возвращаем статус задания по id, и в случае DONE или ERROR имя файла с результатом
		my $status = $struct->{$id}->{status};
		if ($status == Local::TCP::Calc::STATUS_DONE or $status == Local::TCP::Calc::STATUS_ERROR) {
			return [$status, $struct->{$id}->{result}];
		} else {
			return [$status,''];
		}
	} else {
		return ['-1','']
	}
	$self->close($struct);
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
	my $struct = $self->open(1);
	my @keys = grep {$struct->{$_}->{status} == Local::TCP::Calc::STATUS_NEW} keys %{$struct};
	if (@keys) {
		my $k = shift @keys;
		$struct->{$k}->{status} = Local::TCP::Calc::STATUS_WORK;
		# Возвращаем задание, которое необходимо выполнить (id, tasks)
		return [$k, $struct->{$k}->{task}];
	} else {
		return ['0','0'];
	}
	$self->close($struct);
}

sub add {
	my $self = shift;
	my $new_work = shift;
	# Добавляем новое задание с проверкой, что очередь не переполнилась
	my $struct = $self->open(1);
	my @free = sort keys %{{
		map { $_ => undef }
		grep {
			not defined $struct->{$_}
		}
		(1..$self->{max_task})
	}};

	if (@free) {
		my $index = shift @free;
	 	$struct->{$index} = {task => $new_work, status => Local::TCP::Calc->STATUS_NEW() , result => '0'};
		$self->close($struct);
		return 1;
	} else {
		$self->close($struct);
		return '';
	}
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
