package Keyboard::Consts;

use strict;
use warnings;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use Keyboard::Processor;
use base qw(Exporter);
our @EXPORT = qw($hash_keys);

our $hash_keys = {
    '10'       => {
        default => {
            sub => \&Keyboard::Processor::enter,
            args => [],
        }
    },
    '96'       => {
        default  => {
            sub  => \&Keyboard::Processor::exit,
            args => undef,
        },
    },
    '27'       => {
        default  => {
            sub  => \&Keyboard::Processor::esc,
            args => KEYBOARD_ESC,
        },
    },
    '113'       => {
        default  => {
            sub  => \&Keyboard::Processor::esc,
            args => KEYBOARD_ESC,
        },
    },
    '32'       => KEYBOARD_SPACE,
    '27_91_68' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_LEFT,
        },
        target  => {
            sub  => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_LEFT,
        },
    },
    '27_91_67' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_RIGHT,
        },
        target  => {
            sub  => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_RIGHT,
        },
    },
    '27_91_66' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_DOWN,
        },
        target  => {
            sub => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_DOWN,
        },
    },
    '27_91_65' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_UP,
        },
        target  => {
            sub  => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_UP,
        },
    },
    '97'       => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_LEFT,
        },
        target  => {
            sub  => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_LEFT,
        },
    },
    '100' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_RIGHT,
        },
        target  => {
            sub => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_RIGHT,
        }
    },
    '115' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_DOWN,
        },
        target  => {
            sub => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_DOWN,
        },
    },
    '119' => {
        default  => {
            sub  => \&Keyboard::Processor::char_move,
            args => KEYBOARD_MOVE_UP,
        },
        target  => {
            sub => \&Keyboard::Processor::target_move,
            args => KEYBOARD_TARGET_UP,
        },
    },
    '108'      => {
        default  => {
            sub  => \&Keyboard::Processor::chooser_move,
            args => KEYBOARD_RIGHT,
        },
    },
    '104'      => {
        default  => {
            sub  => \&Keyboard::Processor::chooser_move,
            args => KEYBOARD_LEFT,
        },
    },
    '107'      => {
        default  => {
            sub  => \&Keyboard::Processor::chooser_move,
            args => KEYBOARD_UP,
        },
    },
    '106'      => {
        default  => {
            sub  => \&Keyboard::Processor::chooser_move,
            args => KEYBOARD_DOWN,
        },
    },
    '114'      => {
        default  => {
            sub  => \&Keyboard::Processor::scroll_text,
            args => KEYBOARD_TEXT_UP,
        },
    },
    '102'      => {
        default  => {
            sub  => \&Keyboard::Processor::scroll_text,
            args => KEYBOARD_TEXT_DOWN,
        },
    },
    '60'       => {
        default  => {
            sub  => \&Keyboard::Processor::move_item,
            args => KEYBOARD_MOVE_ITEM_LEFT,
        },
    },
    '62'       => {
        default  => {
            sub  => \&Keyboard::Processor::move_item,
            args => KEYBOARD_MOVE_ITEM_RIGHT,
        },
    },
    '105'       => {
        default  => {
            sub  => \&Keyboard::Processor::inv,
            args => undef,
        },
    },
    '112'       => {
        default  => {
            sub  => \&Keyboard::Processor::console,
            args => undef,
        },
    },
    '117'       => {
        default  => {
            sub  => \&Keyboard::Processor::craft,
            args => undef,
        },
    },
    '101'       => {
        default  => {
            sub  => \&Keyboard::Processor::used_item,
            args => undef,
        },
    },
    '45'       => {
        default  => {
            sub  => \&Keyboard::Processor::create_event_minus,
            args => undef,
        },
    },
    '111'      => {
        default => {
            sub => \&Keyboard::Processor::char,
            args => undef,
        }
    },
    '70'       => {
        default => {
            sub => \&Keyboard::Processor::target_on_off,
            args => undef,
        }
    },
};
