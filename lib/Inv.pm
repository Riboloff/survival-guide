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
        'bag' => Bag->new([7, 3, 2, 5, 5, 6]),
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

1;
