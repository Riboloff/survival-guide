package Equip;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Cell;
use Bag;
use Consts;

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
    my $text = shift;

    if ($item->get_type ne 'equipment') {
        return;
    }

    my $slot = $item->get_slot();

    my $bag = $self->{$slot}{bag};

    $bag->put_item($item);
    $text->add_text(Utils::get_random_line($item->{used}{text}));
}

sub get_all_items {
    my $self = shift;

    my $items = [];
    for my $slot (keys %$self) {
        my $bag = $self->{$slot}{bag};
        my @items_slot = map {$_->{item}} @{$bag->get_all_items()};
        push @$items, @items_slot;
    }

    return $items;
}

1;
