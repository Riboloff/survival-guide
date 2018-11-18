package Cell;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Door;
use Stair;
use Item;
use Action;
use Consts;
use Language;
use Logger qw(dmp);
use Wall;

sub new {
    my $self   = shift;
    my $symbol = shift || '';
    my $conf   = shift;
    my $coord  = shift;

    $coord = [split(/,/, $coord)];
    my $icon = {
        symbol => $symbol,
        color  => '',
    };
    my $cell = {
        'icon' => $icon,
        'blocker' => 0,
        'type' => '',
        'objs' => [],
    };
    if ($symbol eq 'C' and (ref $conf eq 'HASH') ) {
        $icon = $cell->{icon} = $conf->{icon};
        $cell->{type} = $conf->{type};
        $cell->{blocker} = $conf->{blocker} || 1;

        $cell->{name_id} = $conf->{name_id};
        my $actions_id = $conf->{actions_id};
        my $actions = _get_actions($actions_id);
        my $items_id = $conf->{items_id};
        push(@{$cell->{objs}}, Container->new($icon, $cell->{name_id}, $actions, $items_id));
    }
    elsif ($symbol eq 'D' and (ref $conf eq 'HASH') ) {
        $icon = $cell->{icon} = $conf->{icon};
        $cell->{type} = $conf->{type};
        $cell->{blocker} = $conf->{blocker} || 1;
        $cell->{name_id} = $conf->{name_id};
        my $actions_id = $conf->{actions_id};
        my $actions = _get_actions($actions_id);
        push(@{$cell->{objs}}, Door->new(
            {
                icon     => $icon,
                proto_id => $cell->{name_id},
                actions  => $actions,
                coord    => $coord,
                blocker  => $cell->{blocker},
                lockpick => $conf->{lockpick},
            }
        ));
    }
    elsif ($symbol eq 'S' and (ref $conf eq 'HASH') ) {
        $cell->{blocker} = 0;
        $cell->{type} = $conf->{type};
        $cell->{name_id} = $conf->{name_id};
        my $map_name = $conf->{map_name};
        my $coord_enter = $conf->{coord_enter};
        my $actions_id = $conf->{actions_id};
        my $actions = _get_actions($actions_id);
        push(@{$cell->{objs}}, Stair->new($icon, $cell->{name_id}, $map_name, $coord_enter, $actions));
    }
    elsif ($symbol =~ /[-|+]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'wall';
        my $icon = {
            symbol => $symbol,
            color => 'red',
        };
        push(@{$cell->{objs}}, Wall->new($icon));
    }

    bless($cell, $self);

    return $cell;
}

sub get_icon {
    my $self = shift;

    if ($self->get_obj and (exists $self->get_obj->{icon} or exists $self->get_obj->{symbol})) {
        return $self->get_obj->get_icon();
    }
    else {
        return $self->{icon};
    }
}

sub set_icon {
    my $self = shift;
    my $icon = shift;

    $self->{icon} = $icon;
}


sub get_type {
    my $self = shift;

    return $self->{type};
}

sub get_obj {
    my $self = shift;

    #return $self->{objs}->[-1];
    return $self->{objs}->[0];
}

sub get_all_objs {
    my $self = shift;

    return $self->{objs};
}

sub _get_items {
    my $items_id = shift;

    my $items = [];
    for my $id (@$items_id) {
        push(@$items, Item->new($id));
    }

    return $items;
}

sub _get_actions {
    my $actions_id = shift;

    my $actions = [];
    for my $id (@$actions_id) {
        push(@$actions, Action->new($id));
    }

    return $actions;
}

sub get_blocker {
    my $self = shift;
    
    if ($self->get_obj and exists $self->get_obj->{blocker}) {
        return $self->get_obj->{blocker};
    } else {
        return $self->{blocker};
    }
}

1;
