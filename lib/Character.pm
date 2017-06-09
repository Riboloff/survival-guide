package Character;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Health;
use Hunger;
use Thirst;

sub new {
    my $self = shift;
    my $start_coord = shift;

    my $start_hp = '23';
    my $start_food = '32';
    my $start_water = '42';

    my $character = {
        coord => $start_coord,
        symbol => 'A',
        needs => {
            health => Health->new($start_hp),
            hunger => Hunger->new($start_food),
            thirst => Thirst->new($start_water),
        }
    };

    bless($character, $self);

    return $character;
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

1;
