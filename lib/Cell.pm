package Cell;

use strict;
use warnings;

use lib qw/lib/;
use Container;
use Item;
use utf8;

sub new {
    my $self = shift;
    my $element = shift || '';

    my $cell = {
        'element' => $element,
        'blocker' => 0,
        'type' => '',
        'obj' => '',
    };

    if ($element =~ /[-|+]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'wall';
    }
    if ($element =~ /[⊟]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Полка', _create_items_for_test(4), ['открыть', 'взломать']);
    }
    if ($element =~ /[⊔]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Коробка', _create_items_for_test(3), ['открыть', 'взломать', 'посмотреть']);
    }
    if ($element =~ /[⁘]/) {
        $cell->{blocker} = 1;
        $cell->{type} = 'Container';
        $cell->{obj} = Container->new('Куча мусора', _create_items_for_test(5), ['посмотреть', 'открыть', 'взломать']);
    }

    bless($cell, $self);

    return $cell;
}

sub get_element {
    my $self = shift;

    return $self->{element};
}


sub get_type {
    my $self = shift;

    return $self->{type};
}

sub get_obj {
    my $self = shift;

    return $self->{obj};
}

sub _create_item_for_test {
    my $name = 'предмет' . int(rand(10));
    my $type = 'loot';
    my $item = Item->new($name, $type);

    return $item;
}

sub _create_items_for_test {
    my $count = shift;

    my $items = [];
    for (0 .. $count) {
        my $name = 'предмет' . int(rand(10));
        my $type = 'loot';
        push(@$items, Item->new($name, $type));
    }
    return $items;
}

1;
