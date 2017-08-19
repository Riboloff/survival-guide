package Craft;

use strict;
use warnings;
use utf8;

use lib qw(lib);
use Logger qw(dmp);
use Storable qw(dclone);
use CraftTable;
use Item;
use Bag;

sub new {
    my $self = shift;
    my $bag_real = shift;

    my $bag_virt = dclone($bag_real);
    my $craft = {
        'craft_place_bag' => Bag->new(),
        'inv_bag' => $bag_virt,
        'craft_result_bag' => Bag->new(),
    };

    bless($craft, $self);

    return $craft;
}

sub get_craft_place_bag {
    my $self = shift;

    return $self->{craft_place_bag};
}

sub get_craft_result_bag {
    my $self = shift;

    return $self->{craft_result_bag};
}

sub get_inv_bag {
    my $self = shift;

    return $self->{inv_bag};
}

#Не используется :(
sub add_items {
    my $self = shift;
    my $positin_item = shift;

    my ($item) = splice(@{$self->{inv}}, $positin_item, 1);
    push(@{$self->{items_in_craft_place}}, $item);
}

#Не используется :(
sub clean_craft_place {
    my $self = shift;

    $self->{items_in_craft_place} = {};
}

sub create_preview {
    my $self = shift;

    my $items = $self->get_craft_place_bag->get_items_hash(); 
    if (! %$items) {
        return [];
    }
    my @proto_ids = keys %{ $items || {} };
    my $key_craft_table = join('_', sort  @proto_ids);

    my $preview_item_id;
    if (exists $CraftTable::craft_table{$key_craft_table}) {
        my $preview_hash = $CraftTable::craft_table{$key_craft_table};
        for my $ingredient (keys %{$preview_hash->{count}}) {
            my $count_need = $preview_hash->{count}{$ingredient};
            my $count  = $items->{$ingredient}{count};
            if ($count < $count_need) {
                return [];
            }
        }
        $preview_item_id = $preview_hash->{result};
    }
    my $result_bag = $self->get_craft_result_bag;
    $result_bag->clean();
    if ($preview_item_id) {
        my $item = Item->new($preview_item_id);
        $result_bag->put_item($item);
    }

    return $result_bag->get_all_items();
}

1;
