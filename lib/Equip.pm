package Equip;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Cell;
use Bag;
use Consts;
use Logger qw(dmp);

sub new {
    my $self = shift;

    my $equip = {
        slot => {
            'head' => {
                'name' => 'голова',
                'number' => 1,
                'bag' => Bag->new(),
            },
            'trunk' => {
                'name' => 'торс',
                'number' => 2,
                'bag' => Bag->new(),

            },
            'lags' => {
                'name' => 'ноги',
                'number' => 3,
                'bag' => Bag->new(),
            },
            'heands' => {
                'name' => 'руки',
                'number' => 4,
                'bag' => Bag->new(),
            },
            'foots' => {
                'name' => 'ступни',
                'number' => 5,
                'bag' => Bag->new(),
            },
        },
        default_volume => 5,
    };

    bless($equip, $self);

    return $equip;
}

sub get_bag {
    my $self = shift;
    my $slot = shift;

    return $self->{slot}{$slot}{bag};
}

sub clothe_item {
    my $self = shift;
    my $item = shift;
    my $char = shift;
    my $text = shift;

    if ($item->get_type ne 'equipment') {
        return;
    }

    my $slot = $item->get_slot();
    my $bag = $self->{slot}{$slot}{bag};
    if ($bag->get_count_item($item->get_proto_id) >= 2) {
        return;
    }
    $bag->put_item($item);
    $text->add_text(Utils::get_random_line($item->{used}{text}));
    #my $warn = $item->get_warm();
    #$char->get_temp()->add_bonus_equip($warn);

    return 1;
}

sub unclothe_item {
    my $self = shift;
    my $item = shift;
    my $char = shift;
    my $text = shift;

    if ($item->get_type ne 'equipment') {
        return;
    }
    my $slot = $item->get_slot();
    my $bag = $char->get_inv->get_bag();
    $bag->put_item($item);

    return 1;
    
}

sub get_all_items {
    my $self = shift;

    my $items = [];
    for my $slot (keys %{$self->{slot}}) {
        my $bag = $self->{slot}{$slot}{bag};
        my @items_slot = ();
        for my $item_count (@{$bag->get_all_items()}) {
            for (1 .. $item_count->{count}) {
                push(@items_slot, $item_count->{item});
            }
        }
        push @$items, @items_slot;
    }

    return $items;
}

sub get_max_volume {
    my $self = shift;

    my $all_items = $self->get_all_items();

    my $count_max_volume = $self->{default_volume};
    for my $item (@$all_items) {
        $count_max_volume += $item->get_add_volume() // 0;
    }

    return $count_max_volume;
}

sub get_all_weight {
    my $self = shift;

    my $all_items = $self->get_all_items();
    my $weight_all = 0;
    for my $item (@$all_items) {
        my $weight = $item->{weight} // 0;
        $weight_all += $weight;
    }

    return $weight_all;
}

sub get_all_volume {
    my $self = shift;

    my $all_items = $self->get_all_items();
    my $volume_all = 0;
    for my $item (@$all_items) {
        my $volume = $item->{volume} // 0;
        $volume_all += $volume;
    }

    return $volume_all;
}

1;
