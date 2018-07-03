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
        '$items_id', '$objects_id', '$actions_id',
        (grep {$_ =~ /^(AC|OB|IT|ICON|DE|KEYBOARD)_/} keys %{__PACKAGE__ . '::'}),
    );
}
our $X = 1;
our $Y = 0;

#Размеры блоков интерфейса 
#определяются по двух точкам левого верннего и правого нижнего угла
our $LT = 0; #Left top
our $RD = 1; #right down

my ($wchar, $hchar) = GetTerminalSize();
$wchar--;
$hchar--;

our $size_term = [$hchar, $wchar];

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
    eval IT_PAINKILLER     => 'painkiller',
    eval IT_LOCKPICK       => 'lockpick',
};

our $objects_id = {
    eval OB_SHELF => 'shelf',
    eval OB_DOOR  => 'door',
    eval OB_STAIR_UP   => 'stair_up',
    eval OB_STAIR_DOWN => 'stair_down',
    eval OB_BOT_ZOMBIE => 'bot_zombie',
    eval OB_BOT_DOG => 'bot_dog',
    eval OB_CHAR => 'char',
    eval OB_WALL => 'wall',
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
    IT_PAINKILLER     => 10,
    IT_LOCKPICK       => 11,

    #Objects:
    OB_SHELF => 1,
    OB_DOOR  => 2,
    OB_STAIR_UP   => 3,
    OB_STAIR_DOWN => 4,
    OB_BOT_ZOMBIE => 5,
    OB_BOT_DOG => 6,
    OB_CHAR => 7,
    OB_WALL => 8,

    #Icon
    ICON_CLOSE_DOOR => 'X',
    ICON_OPEN_DOOR  => 'O',

    #deseases
    DE_BLEEDING => 1,
    DE_PAIN => 2,

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
    KEYBOARD_TARGET_ON_OFF => 21,
    KEYBOARD_TARGET_LEFT   => 22,
    KEYBOARD_TARGET_RIGHT  => 23,
    KEYBOARD_TARGET_DOWN   => 24,
    KEYBOARD_TARGET_UP     => 25,
    KEYBOARD_SPACE         => 26,
};

1;
