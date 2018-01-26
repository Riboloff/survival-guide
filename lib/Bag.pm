package Bag;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Cell;
use Logger qw(dmp);

sub new {
    my $self = shift;
    my $item_proto_ids = shift || [];

    my $items = {};
    for my $proto_id (@$item_proto_ids) {
        if (!exists $items->{$proto_id}) {
            $items->{$proto_id}{item} = Item->new($proto_id);
            $items->{$proto_id}{count} = 1;
        }
        else {
            $items->{$proto_id}{count}++;
        }
    }

    my $bag = {
        items => $items,
    };

    bless($bag, $self);

    return $bag;
}

sub clean {
    my $self = shift;

    $self->{items} = {};
}

sub splice_item {
    my $self = shift;
    my $proto_id = shift;

    my $item = $self->{items}{$proto_id};

    if ($item) {
        $item->{count}--;
        if ($item->{count} == 0) {
            delete $self->{items}{$proto_id};
        }
        return $item->{item};
    }

    return;
}

sub get_items_hash {
    my $self = shift;

    return $self->{items};
}

sub get_all_items {
    my $self = shift;

    my $all_items = [];
    for my $ptoro_id (sort keys %{$self->{items}}) {
        push(@$all_items, $self->{items}{$ptoro_id});
    }

    return $all_items;
}

sub put_item_proto {
    my $self = shift;
    my $proto_id = shift;

    my $items = $self->{items};
    if (!exists $items->{$proto_id}) {
        $items->{$proto_id}{item} = Item->new($proto_id);
        $items->{$proto_id}{count} = 1;
    }
    else {
        $items->{$proto_id}{count}++;
    }

    return;
}

sub put_item {
    my $self = shift;
    my $item = shift;

    my $proto_id = $item->get_proto_id();
    my $items = $self->{items};
    if (!exists $items->{$proto_id}) {
        $items->{$proto_id}{item} = $item;
        $items->{$proto_id}{count} = 1;
    }
    else {
        $items->{$proto_id}{count}++;
    }

    return;
}

sub get_count_item {
    my $self = shift;
    my $proto_id = shift;

    if (!exists $self->{items}{$proto_id}) {
        return 0;
    }
    return $self->{items}{$proto_id}{count};
}

sub get_all_weight {
    my $self = shift;

    my $all_items = $self->get_all_items();
    my $weight_all = 0;
    for my $pair (@$all_items) {
        my ($item, $count) = @{$pair}{qw/item count/};
        my $weight = $item->{weight} // 0;
        $weight_all += ($weight * $count);
    }

    return $weight_all;
}

sub get_all_volume {
    my $self = shift;

    my $all_items = $self->get_all_items();
    my $volume_all = 0;
    for my $pair (@$all_items) {
        my ($item, $count) = @{$pair}{qw/item count/};
        my $volume = $item->{volume} // 0;
        $volume_all += ($volume * $count);
    }

    return $volume_all;
}

sub has_item {
    my $self = shift;
    my $item_id = shift;

    if (exists $self->{items}{$item_id}) {
        return 1;
    }

    return 0;
}

1;
