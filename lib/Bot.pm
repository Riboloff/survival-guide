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
    my ($start_coord, $symbol, $color, $map) = @_;

    my $bot = {
        coord => $start_coord,
        symbol => $symbol // '?',
        color => $color // 'blue',
        id    => create_id(),
        map_name   => $map->{map_name},
        bot => 1,
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
    my $map = shift;

    my $array_tmp = [KEYBOARD_MOVE_LEFT, KEYBOARD_MOVE_RIGHT, KEYBOARD_MOVE_UP, KEYBOARD_MOVE_DOWN];
    $self->move($map, $array_tmp->[int rand @$array_tmp]);
}

1;
