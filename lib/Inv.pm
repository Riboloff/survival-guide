package Inv;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Cell;
use Bag;
use Equip;

sub new {
    my $self = shift;

    my $inv = {
        'on' => 0,
        'bag' => Bag->new([10, 9, 3, 7, 2, 5, 5, 6]),
        'equipment' => Equip->new(),
    };

    bless($inv, $self);

    return $inv;
}

sub rm_bag_items {
    my $self = shift;
    my $proto_id = shift;
    my $count = shift;

    my $bag = $self->get_bag();
    for (1 .. $count) {
        $bag->splice_item($proto_id);
    }

    return;
}

sub get_bag {
    my $self = shift;

    return $self->{bag};
}

sub get_equipment {
    my $self = shift;

    return $self->{equipment};
}

sub on {
    my $self = shift;

    $self->{on} = 1;
}

sub off {
    my $self = shift;

    $self->{on} = 0;
}

sub get_all_weight {
    my $self = shift;

    my $bag_weight = $self->get_bag->get_all_weight();
    my $equipment_weight = $self->get_equipment->get_all_weight();

    my $all_weight = 0;

    $all_weight = $bag_weight + $equipment_weight;
    return $all_weight;
}

sub get_all_volume {
    my $self = shift;

    my $bag_volume = $self->get_bag->get_all_volume();
    my $equipment_volume = $self->get_equipment->get_all_volume();

    my $all_volume = 0;

    $all_volume = $bag_volume + $equipment_volume;
    return $all_volume;
}

1;
