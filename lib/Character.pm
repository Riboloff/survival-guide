package Character;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Inv;
use Needs::Health;
use Needs::Hunger;
use Needs::Thirst;
use Needs::Temp;
use Needs::Disease;
use Consts;

sub new {
    my $self = shift;
    my $start_coord = shift;

    my $start_hp = '23';
    my $start_food = '32';
    my $start_water = '42';
    my $start_temp = '22';
    my $start_radius_visibility = 6;

    my $inv = Inv->new();
    my $equip = $inv->get_equipment();
    my $id = OB_CHAR;
    my $obj_text = Language::get_text($id, 'objects');
    my $character = {
        look => $obj_text->{look},
        coord => $start_coord,
        icon => {
            symbol => 'Я',
            color => 'red',
        },
        inv => $inv,
        radius_visibility => $start_radius_visibility,
        default_radius_visibility => $start_radius_visibility,
        needs => {
            health  => Needs::Health->new($start_hp),
            hunger  => Needs::Hunger->new($start_food),
            thirst  => Needs::Thirst->new($start_water),
            temp    => Needs::Temp->new($start_temp, $equip),
            disease => Needs::Disease->new(),
        }
    };

    bless($character, $self);

    return $character;
}

sub get_look {
    my $self = shift;

    return $self->{look};
}

sub get_inv {
    my $self = shift;

    return $self->{inv};
}

sub get_radius_visibility {
    my $self = shift;

    return $self->{radius_visibility};
}

sub set_radius_visibility {
    my $self = shift;
    my $radius_visibility = shift;

    $self->{radius_visibility} = $radius_visibility;
}

sub reset_radius_visibility {
    my $self = shift;

    $self->{radius_visibility} = $self->{default_radius_visibility};
}

sub get_coord {
    my $self = shift;

    return $self->{coord};
}

sub get_health {
    my $self = shift;

    return $self->{needs}{health};
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}

sub get_hunger {
    my $self = shift;

    return $self->{needs}{hunger};
}

sub get_thirst {
    my $self = shift;

    return $self->{needs}{thirst};
}

sub get_temp {
    my $self = shift;

    return $self->{needs}{temp};
}

sub get_disease {
    my $self = shift;

    return $self->{needs}{disease};
}

sub get_color {
    my $self = shift;

    return $self->{color};
}

sub is_enable_craft {
    my $self = shift;

    if ($self->get_disease->is_disease('pain')) {
        $self->{cause_no_enable_craft} = 'pain';
        return 0;
    }

    return 1;
}

sub get_cause_no_enable_craft {
    my $self = shift;

    return $self->{cause_no_enable_craft};
}

sub move {
    my $self    = shift;
    my $map_obj = shift;
    my $move    = shift;

    if (
        $self->{bot}
        and $map_obj->{map_name} ne $self->{map_name}
    ) {
        return;
    }
    my $x = $self->{coord}[$X];
    my $y = $self->{coord}[$Y];

    my $map = $map_obj->{map};

    if ($move == KEYBOARD_MOVE_RIGHT) {
        if ($x + 1 < @{$map->[$y]}) {
            $x++;
        }
    } elsif ($move == KEYBOARD_MOVE_LEFT) {
        if ($x > 0) {
            $x--;
        }
    } elsif ($move == KEYBOARD_MOVE_UP) {
        if ($y > 0) {
            $y--;
        }
    } elsif ($move == KEYBOARD_MOVE_DOWN) {
        if ($y + 1 < @$map) {
            $y++;
        }
    }
    my $cell = $map->[$y][$x];

    if ($cell->get_blocker) {
        return 0;
    }

    $self->get_coord->[$X] = $x;
    $self->get_coord->[$Y] = $y;

    return 1;
}

1;
