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
        head => {
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
    };

    bless($equip, $self);

    return $equip;
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
    
    my $bag = $self->{$slot}{bag};
    if ($bag->get_count_item($item->get_proto_id) >= 2) {
        return;
    }
    $bag->put_item($item);
    $text->add_text(Utils::get_random_line($item->{used}{text}));
    my $warn = $item->get_warm();
    $char->get_temp()->add_bonus_equip($warn);

    return 1;
}

sub get_all_items {
    my $self = shift;

    my $items = [];
    for my $slot (keys %$self) {
        my $bag = $self->{$slot}{bag};
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

1;
