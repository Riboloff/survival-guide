package Consts;

use strict;
use warnings;

use Term::ReadKey;
use Term::Cap;
use lib qw(lib);

use Exporter 'import';
our @EXPORT = qw(
    $X $Y
    $LT $RD
    $size_term
    $items_id $objects_id $actions_id
);

our $X = 1;
our $Y = 0;

#Размеры блоков интерфейса
our $LT = 0; #Left top
our $RD = 1; #reatht down

my ($wchar, $hchar) = GetTerminalSize();
$wchar--;
$hchar--;

our $size_term = [$hchar, $wchar];

our $items_id = {
    1 => 'medicine_box',
};

our $objects_id = {
    1 => 'shelf',
};

our $actions_id = {
    1 => 'open',
    2 => 'watch',
    3 => 'lockpick',
};

use constant OPEN     => 1;
use constant WATCH    => 2;
use constant LOCKPICK => 3;

1;
