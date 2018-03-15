package Keyboard;

use strict;
use warnings;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);

my $hash_keys = {
    '10'       => KEYBOARD_ENTER,
    '96'       => KEYBOARD_BACKQUOTE,
    '27'       => KEYBOARD_ESC,
    '113'      => KEYBOARD_ESC,
    '27_91_68' => {
        default => KEYBOARD_MOVE_LEFT,
        target  => KEYBOARD_TARGET_LEFT,
    },
    '27_91_67' => {
        default => KEYBOARD_MOVE_RIGHT,
        target  => KEYBOARD_TARGET_RIGHT,
    },
    '27_91_66' => {
        default => KEYBOARD_MOVE_DOWN,
        target  => KEYBOARD_TARGET_DOWN,
    },
    '27_91_65' => {
        default => KEYBOARD_MOVE_UP,
        target  => KEYBOARD_TARGET_UP,
    },
    '97'       => {
        default => KEYBOARD_MOVE_LEFT,
        target  => KEYBOARD_TARGET_LEFT,
    },
    '100' => {
        default => KEYBOARD_MOVE_RIGHT,
        target  => KEYBOARD_TARGET_RIGHT,
    },
    '115' => {
        default => KEYBOARD_MOVE_DOWN,
        target  => KEYBOARD_TARGET_DOWN,
    },
    '119' => {
        default => KEYBOARD_MOVE_UP,
        target  => KEYBOARD_TARGET_UP,
    },
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
    '70'       => KEYBOARD_TARGET_ON_OFF,
};

my $mods = {};

sub get_action {
    my @button = @_;

    my $action = 0;

    my $key = join('_', @button);
    if (ref $hash_keys->{$key} eq 'HASH') {
        ($action) = @{$hash_keys->{$key}}{ keys %$mods};
        $action //= $hash_keys->{$key}{default};
    }
    else {
        $action = $hash_keys->{$key};
    }

    return $action;
}

sub set_or_rm_mod {
    my $mod = shift;

    if (exists $mods->{$mod}) {
        delete $mods->{$mod};
    }
    else {
        $mods->{$mod} = 1;
    }
}

1;
