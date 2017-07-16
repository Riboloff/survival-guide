package Inv;

use strict;
use warnings;

use lib qw/lib/;
use Container;
use Cell;
use utf8;

sub new {
    my $self = shift;

    my $inv = {
        'on' => 0,
        'bag' => {
            'items' => Cell::_get_items([3,2]),
        },
        'harness' => {
            head => {
                'name' => 'голова',
                'items' => ['кепка'],
                'number' => 1,
            },
            'trunk' => {
                'name' => 'торс',
                'items' => ['майка', 'рубашка'],
                'number' => 2,

            },
            'lags' => {
                'name' => 'ноги',
                'items' => ['шорты'],
                'number' => 3,
            },
            'heands' => {
                'name' => 'руки',
                'items' => [''],
                'number' => 4,
            },
            'foots' => {
                'name' => 'ступни',
                'items' => ['носки', 'ботинки'],
                'number' => 5,
            },
        }
    };

    bless($inv, $self);

    return $inv;
}

sub add_bag_item {
    my $self = shift;
    my $item = shift;

    push(@{$self->{bag}{items}}, $item);
}

sub rm_bag_item {
    my $self = shift;
    my $item_id = shift;

    my $items_bag = $self->get_all_items_bag();
    for (my $i=0; $i < @$items_bag; ++$i ) {
        my $item = $items_bag->[$i];
        if ($item->{id} eq $item_id) {
            splice(@$items_bag, $i, 1);
            last;
        }
    }

    return;
}

sub get_all_items_bag {
    my $self = shift;

    return $self->{bag}{items};
}

sub get_harness {
    my $self = shift;

    return $self->{harness};
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
