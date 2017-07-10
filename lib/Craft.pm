package Craft;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Logger qw(dmp);
use Storable qw(dclone);
use CraftTable;
use Item;

sub new {
    my $self = shift;
    my $bag_real = shift;

    my $bag_virt = dclone($bag_real);
    my $craft = {
        'list_items' => [],
        'bag' => $bag_virt,
        'craft_result' => [],
    };

    bless($craft, $self);

    return $craft;
}

sub get_list_items {
    my $self = shift;

    return $self->{list_items};
}

sub get_craft_result {
    my $self = shift;

    return $self->{craft_result};
}

sub get_bag {
    my $self = shift;

    return $self->{bag};
}

sub add_items {
    my $self = shift;
    my $positin_item = shift;

    my ($item) = splice(@{$self->{inv}}, $positin_item, 1);
    push(@{$self->{list_items}}, $item);
}

sub clean_items {
    my $self = shift;

    $self->{list_items} = [];
}

sub create_preview {
    my $self = shift;
    if (! scalar @{$self->{list_items}}) {
        return [];
    }
    my @proto_ids = map{ $_->get_proto_id() } @{$self->{list_items}};
    my $key_craft_table = join('_', sort  @proto_ids);

    my $preview_item_ids = [];
    if (exists $CraftTable::craft_table{$key_craft_table}) {
        $preview_item_ids = $CraftTable::craft_table{$key_craft_table};

    }
    my $preview_items = [];
    for my $ids (@$preview_item_ids) {
        my $item = Item->new(undef,undef,$ids);
        push(@$preview_items, $item->get_name());
    }
    $self->{craft_result} = $preview_items;
    return $preview_items;
}

1;
