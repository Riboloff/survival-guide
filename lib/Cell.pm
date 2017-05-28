package Cell;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Item;
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
       my $obj_text = Language::get_text_object($cell->{name_id});
       my $name = $obj_text->{name}; 
       my $desc = $obj_text->{desc};
       my $items_id = $conf->{items_id};
       my $actions = $conf->{actions};
       my $items = _get_items($items_id);
       $cell->{obj} = Container->new($name, $items, $actions);
    }
    if ($icon =~ /[-|+]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'wall';
    }
    if ($icon =~ /[⊟]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Полка', _create_items_for_test(4), ['открыть', 'взломать']);
    }
    if ($icon =~ /[⊔]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Коробка', _create_items_for_test(3), ['открыть', 'взломать', 'посмотреть']);
    }
    if ($icon =~ /[⁘]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Куча мусора', _create_items_for_test(5), ['посмотреть', 'открыть', 'взломать']);
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
        my $file_name = $Consts::items_id->{$id};
        my $hash = Language::read_json_file("text/items/$file_name");
        my $desc = Text->new(undef, $hash->{desc});
        my $name = $hash->{name};
        push(@$items, Item->new($name, $desc));
    }

    return $items;
}

1;
