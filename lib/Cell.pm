package Cell;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Item;
use Action;
use Consts;
use Language;
use Logger qw(dmp);

sub new {
    my $self = shift;
    my $icon = shift || '';
    my $conf = shift;
    my $cord = shift;


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
       my $obj_text = Language::get_text($cell->{name_id}, 'objects');
       my $name = $obj_text->{name}; 
       my $desc = $obj_text->{desc};
       my $items_id = $conf->{items_id};
       my $actions_id = $conf->{actions_id};
       my $actions = _get_actions($actions_id);
       my $items = _get_items($items_id);
       $cell->{obj} = Container->new($name, $items, $actions);
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

sub _create_items_for_test {
    my $count = shift;

    my $items = [];
    for (0 .. $count) {
        my $name = 'предмет' . int(rand(10));
        my $file_name = 'desc_item';
        $file_name .=  int(rand(3)) + 1;
        my $desc = Text->new($file_name);
        push(@$items, Item->new($name, $desc));
    }

    return $items;
}

sub _get_items {
    my $items_id = shift;

    my $items = [];
    for my $id (@$items_id) {
        my $hash = Language::get_text($id, 'items');
        my $desc = Text->new(undef, $hash->{desc});
        my $name = $hash->{name};
        push(@$items, Item->new($name, $desc, $id));
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
