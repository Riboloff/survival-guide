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
        (grep {$_ =~ /^(AC|OB|IT|ICON|DE|KEYBOARD)_/} keys %{__PACKAGE__ . '::'}),
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
our $text_inform_dir    = 'text/inform';
our $text_disease_dir   = 'text/disease';


our $items_id = {
    eval IT_MEDICINE_BOX   => 'medicine_box',
    eval IT_BREAD          => 'bread',
    eval IT_WATER          => 'water',
    eval IT_SOFT_BREAD     => 'soft_bread',
    eval IT_CAP            => 'cap',
    eval IT_FURCAP         => 'fur_cap',
    eval IT_FLASHLIGHT_OFF => 'flashlight_off',
    eval IT_FLASHLIGHT_ON  => 'flashlight_on',
    eval IT_BACKPACK       => 'backpack',
};

our $objects_id = {
    eval OB_SHELF => 'shelf',
    eval OB_DOOR  => 'door',
    eval OB_STAIR_UP   => 'stair_up',
    eval OB_STAIR_DOWN => 'stair_down',
};

our $actions_id = {
    eval AC_OPEN     => 'open',
    eval AC_WATCH    => 'watch',
    eval AC_LOCKPICK => 'lockpick',
    eval AC_CLOSE    => 'close',
    eval AC_DOWN     => 'down',
    eval AC_UP       => 'up',
};

use constant {
    #Actions:
    AC_OPEN     => 1,
    AC_WATCH    => 2,
    AC_LOCKPICK => 3,
    AC_CLOSE    => 4,
    AC_DOWN     => 5,
    AC_UP       => 6,

    #Items:
    IT_MEDICINE_BOX   => 1,
    IT_BREAD          => 2,
    IT_WATER          => 3,
    IT_SOFT_BREAD     => 4,
    IT_CAP            => 5,
    IT_FURCAP         => 6,
    IT_FLASHLIGHT_OFF => 7,
    IT_FLASHLIGHT_ON  => 8,
    IT_BACKPACK       => 9,

    #Objects:
    OB_SHELF => 1,
    OB_DOOR  => 2,
    OB_STAIR_UP   => 3,
    OB_STAIR_DOWN => 4,

    #Icon
    ICON_CLOSE_DOOR => 'X',
    ICON_OPEN_DOOR  => 'O',

    #deseases
    DE_BLEEDING => 1,

    #keys ord
    KEYBOARD_ENTER       => 1,
    KEYBOARD_BACKQUOTE   => 2,
    KEYBOARD_ESC         => 3,
    KEYBOARD_MOVE_LEFT   => 4,
    KEYBOARD_MOVE_RIGHT  => 5,
    KEYBOARD_MOVE_DOWN   => 6,
    KEYBOARD_MOVE_UP     => 7,
    KEYBOARD_RIGHT       => 8,
    KEYBOARD_LEFT        => 9,
    KEYBOARD_UP          => 10,
    KEYBOARD_DOWN        => 11,
    KEYBOARD_TEXT_UP     => 12,
    KEYBOARD_TEXT_DOWN   => 13,
    KEYBOARD_MOVE_ITEM_RIGHT => 14,
    KEYBOARD_MOVE_ITEM_LEFT  => 15,
    KEYBOARD_INV => 16,
    KEYBOARD_CRAFT => 17,
    KEYBOARD_USED => 18,
    KEYBOARD_MINUS => 19,
    KEYBOARD_CHAR => 20,
};

1;
