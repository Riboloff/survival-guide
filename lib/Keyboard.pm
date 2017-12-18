package Keyboard;

use strict;
use warnings;

use lib qw/lib/;
use Consts;

my $hash_keys = {
    '10'       => KEYBOARD_ENTER,
    '96'       => KEYBOARD_BACKQUOTE,
    '27'       => KEYBOARD_ESC,
    '113'      => KEYBOARD_ESC,
    '27_91_68' => KEYBOARD_MOVE_LEFT,
    '27_91_67' => KEYBOARD_MOVE_RIGHT,
    '27_91_66' => KEYBOARD_MOVE_DOWN,
    '27_91_65' => KEYBOARD_MOVE_UP,
    '97'       => KEYBOARD_MOVE_LEFT,
    '100'      => KEYBOARD_MOVE_RIGHT,
    '115'      => KEYBOARD_MOVE_DOWN,
    '119'      => KEYBOARD_MOVE_UP,
    '108'      => KEYBOARD_RIGHT,
    '104'      => KEYBOARD_LEFT,
    '107'      => KEYBOARD_UP,
    '106'      => KEYBOARD_DOWN,
    '114'      => KEYBOARD_TEXT_UP,
    '102'      => KEYBOARD_TEXT_DOWN,
    '60'       => KEYBOARD_MOVE_ITEM_RIGHT,
    '62'       => KEYBOARD_MOVE_ITEM_LEFT,
    '105'      => KEYBOARD_INV,
    '117'       => KEYBOARD_CRAFT,
    '101'      => KEYBOARD_USED,
    '45'       => KEYBOARD_MINUS,
    #'99'       => KEYBOARD_CHAR,
    '111'      => KEYBOARD_CHAR,

};

sub get_button {
    my @keys = @_;

    my $key = join('_', @keys);
    return $hash_keys->{$key};
}

1;
