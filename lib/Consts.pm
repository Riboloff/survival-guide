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
    $item_dir
    $text_objects_dir
    $items_id $objects_id $actions_id
);

our $X = 1;
our $Y = 0;

#Размеры блоков интерфейса 
#определяются по двух точкам левого верннего и правого нижнего угла
our $LT = 0; #Left top
our $RD = 1; #reatht down

my ($wchar, $hchar) = GetTerminalSize();
$wchar--;
$hchar--;

our $size_term = [$hchar, $wchar];

our $item_dir = 'proto/items/';
our $text_objects_dir = 'text/objects/';

our $items_id = {
    1 => 'medicine_box',
    2 => 'bread',
    3 => 'water',
    4 => 'soft_bread',
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

use constant MEDICINE_BOX => 1;
use constant BREAD => 2;
use constant WATER => 3;
use constant SOFT_BREAD => 4;

use constant SHELF => 1;

1;
