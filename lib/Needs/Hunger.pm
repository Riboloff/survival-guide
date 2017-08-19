package Needs::Hunger;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Logger qw(dmp);

sub new {
    my $self = shift;
    my $start_food = shift;

    my $hunger = {
        'food' => $start_food,
        'time_dec_one'  => 7,
    };

    bless($hunger, $self);

    return $hunger;
}

sub get_time_dec_one {
    my $self = shift;

    return $self->{time_dec_one};
}

sub get_food {
    my $self = shift;

    return $self->{food};
}

sub add_food {
    my $self = shift;
    my $food_add = shift;

    my $food = $self->{food};
    $food += $food_add;
    $food = Utils::clamp($food, 0, 100);
    $self->{food} = $food;
}

sub sub_food {
    my $self = shift;
    my $food_sub = shift;

    my $food = $self->{food};
    $food -= $food_sub;
    $food = Utils::clamp($food, 0, 100);
    $self->{food} = $food;
}

1;
