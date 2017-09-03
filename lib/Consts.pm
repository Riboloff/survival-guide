package Consts;

use strict;
use warnings;

use Term::ReadKey;
use Term::Cap;
use lib qw(lib);

use base qw(Exporter);
{no strict;
    our @EXPORT = (
        '$X', '$Y',
        '$LT', '$RD',
        '$size_term',
        '$item_dir',
        '$text_objects_dir',
        '$items_id', '$objects_id', '$actions_id',
        (grep {$_ =~ /^(AC|OB|IT)_/} keys %{__PACKAGE__ . '::'}),
    );
}
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

our $item_dir           = 'proto/items/';
our $text_objects_dir   = 'text/objects/';
our $text_interface_dir = 'text/interface';


our $items_id = {
    eval IT_MEDICINE_BOX => 'medicine_box',
    eval IT_BREAD        => 'bread',
    eval IT_WATER        => 'water',
    eval IT_SOFT_BREAD   => 'soft_bread',
    eval IT_CAP          => 'cap',
    eval IT_FURCAP       => 'fur_cap',
};

our $objects_id = {
    eval OB_SHELF => 'shelf',
    eval OB_DOOR  => 'door',
};

our $actions_id = {
    eval AC_OPEN     => 'open',
    eval AC_WATCH    => 'watch',
    eval AC_LOCKPICK => 'lockpick',
};

use constant {
    #Actions:
    AC_OPEN     => 1,
    AC_WATCH    => 2,
    AC_LOCKPICK => 3,

    #Items:
    IT_MEDICINE_BOX => 1,
    IT_BREAD        => 2,
    IT_WATER        => 3,
    IT_SOFT_BREAD   => 4,
    IT_CAP          => 5,
    IT_FURCAP       => 6,

    #Objects:
    OB_SHELF => 1,
    OB_DOOR  => 2,
};

1;
