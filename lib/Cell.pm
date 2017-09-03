package Cell;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Door;
use Item;
use Action;
use Consts;
use Language;
use Logger qw(dmp);

sub new {
    my $self = shift;
    my $icon = shift || '';
    my $conf = shift;
    my $coord = shift;

    $coord = [split(/,/, $coord)];
    my $cell = {
        'icon' => $icon,
        'blocker' => 0,
        'type' => '',
        'obj' => '',
    };
    if ($icon eq 'C' and (ref $conf eq 'HASH') ) {
       $cell->{icon} = $conf->{icon};
       $cell->{type} = $conf->{type};
       $cell->{blocker} = $conf->{blocker} || 1;

       $cell->{name_id} = $conf->{name_id};
       my $actions_id = $conf->{actions_id};
       my $actions = _get_actions($actions_id);
       my $items_id = $conf->{items_id};
       $cell->{obj} = Container->new($cell->{name_id}, $actions, $items_id);
    }
    elsif ($icon eq 'D' and (ref $conf eq 'HASH') ) {
       $cell->{icon} = $conf->{icon};
       $cell->{type} = $conf->{type};
       $cell->{blocker} = $conf->{blocker} || 1;
       $cell->{name_id} = $conf->{name_id};
       my $actions_id = $conf->{actions_id};
       my $actions = _get_actions($actions_id);
       $cell->{obj} = Door->new($cell->{name_id}, $actions, $coord);
    }

    if ($icon =~ /[-|+]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'wall';
    }

    bless($cell, $self);

    return $cell;
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}


sub get_type {
    my $self = shift;

    return $self->{type};
}

sub get_obj {
    my $self = shift;

    return $self->{obj};
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
        my $hash = Language::get_text($id, 'actions');
        my $name = $hash->{name};
        push(@$actions, Action->new($name, $id));
    }

    return $actions;
}

1;
