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

sub new {
    my $self = shift;
    my $start_coord = shift;

    my $start_hp = '23';
    my $start_food = '32';
    my $start_water = '42';
    my $start_temp = '22';

    my $inv = Inv->new();
    my $equip = $inv->get_equipment();
    my $character = {
        coord => $start_coord,
        symbol => 'A',
        inv => $inv,
        needs => {
            health => Needs::Health->new($start_hp),
            hunger => Needs::Hunger->new($start_food),
            thirst => Needs::Thirst->new($start_water),
            temp => Needs::Temp->new($start_temp, $equip),
        }
    };

    bless($character, $self);

    return $character;
}

sub get_inv {
    my $self = shift;

    return $self->{inv};
}

sub get_coord {
    my $self = shift;

    return $self->{coord};
}

sub get_health {
    my $self = shift;

    return $self->{needs}{health};
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

1;
