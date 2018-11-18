package Bot;

use strict;
use warnings;
use utf8;

use base 'Character';
use lib qw/lib/;

use Consts;

my $id = 0;

sub new {
    my $self = shift;
    my ($bot_type, $start_coord, $symbol, $color, $friendly, $map) = @_;

    my $obj_text = Language::get_text($bot_type, 'objects');
    my $actions = [
      Action->new(AC_WATCH),
    ];
    my $bot = {
        coord => $start_coord,
        icon => {
            symbol => $symbol // '?',
            color => $color // 'blue',
        },
        id    => create_id(),
        friendly => $friendly,
        map_name => $map->{map_name},
        bot => 1,
        bot_type => $bot_type,
        name => $obj_text->{name},
        desc => $obj_text->{desc},
        look => $obj_text->{desc},
        actions => $actions,
    };
    bless($bot, $self);

    return $bot;
}

sub get_color {
    my $self = shift;

    return $self->{color};
}

sub get_id {
    my $self = shift;

    return $self->{id};
}

sub create_id {
    return $id++;
}

sub move_bot {
    my $self = shift;
    my $interface = shift;

    my $chosen_direction;
    if ($self->{friendly}) {
        my $array_tmp = [KEYBOARD_MOVE_LEFT, KEYBOARD_MOVE_RIGHT, KEYBOARD_MOVE_UP, KEYBOARD_MOVE_DOWN];
        $chosen_direction = $array_tmp->[int rand @$array_tmp];
    } else {
        my $player = $interface->get_character();
        if ($player->get_coord->[$Y] < $self->get_coord->[$Y]) {
            $chosen_direction = KEYBOARD_MOVE_UP;
        }
        elsif ($player->get_coord->[$Y] > $self->get_coord->[$Y]) {
            $chosen_direction = KEYBOARD_MOVE_DOWN;
        }
        elsif ($player->get_coord->[$X] < $self->get_coord->[$X]) {
            $chosen_direction = KEYBOARD_MOVE_LEFT;
        }
        elsif ($player->get_coord->[$X] > $self->get_coord->[$X]) {
            $chosen_direction = KEYBOARD_MOVE_RIGHT;
        }
    }
    if ($chosen_direction) {
        $self->move($interface, $chosen_direction);
    }
}

sub get_name {
  my $self = shift;

  return $self->{name};
}

sub get_desc {
  my $self = shift;

  return $self->{desc};
}

sub get_actions {
  my $self = shift;

  return $self->{actions};
}

1;
