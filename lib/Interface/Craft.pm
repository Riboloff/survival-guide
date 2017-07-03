package Interface::Craft;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;
use Utils;

sub process_bag {
    my $interface = shift;

    my $craft = $interface->{craft}{obj};

    my $bag = $craft->get_bag;
    my $list_items = $bag->{'items'};
    my $area = $interface->{craft}{bag}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $bag_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{bag} = $list_items;
    my $chooser_position = $chooser->get_position('bag');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$list_items);
    $chooser->set_position('craft_bag', $chooser_position);

    my $color_chooser = 'on_green';
    if ($chooser->{block_name} ne 'craft_bag') {
        $chooser_position = 999;
    }

    my @list_items_name = map {$_->get_name} @$list_items;
    my $args = {
        list => \@list_items_name,
        array => $bag_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => $color_chooser,
    };
    $bag_array = Interface::Utils::list_to_array_symbols($args);
    my $tmp = @{$bag_array->[0]};
    my $bag_frame_array = Interface::Utils::get_frame($bag_array);

    return $bag_frame_array;
}

sub process_craft_items {
    my $interface = shift;

    my $area = $interface->{craft}{place}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $craft_items_array = Interface::Utils::init_array($area, $size_area);

    my $craft = $interface->{craft}{obj};
    my $craft_items_list = $craft->get_list_items();
    my @craft_items_name_list = map {$_->get_name} @$craft_items_list;

    my $chooser = $interface->{chooser};
    my $chooser_position = $chooser->get_position('craft_place');
    $chooser_position = Utils::clamp($chooser_position, 0, $#craft_items_name_list);
    $chooser->set_position('craft_place', $chooser_position);

    if ($chooser->{block_name} ne 'craft_place') {
        my $craft = $interface->{craft}{obj};
        my $bag = $craft->get_bag;
        my $list_items = $bag->{'items'};
        if (scalar @$list_items) {
            $chooser_position = 999;
        } else {
            $chooser->{block_name} = 'craft_place';
        }
    }
    if (
        $chooser->{block_name} eq 'craft_place'
        and !@craft_items_name_list
    ) {
        $chooser->{block_name} = 'craft_bag';
    }

    my $args = {
        list => \@craft_items_name_list,
        array => $craft_items_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => 'on_green',
    };

    $craft_items_array = Interface::Utils::list_to_array_symbols($args);
    my $craft_items_frame_array = Interface::Utils::get_frame($craft_items_array);

    return $craft_items_frame_array;
}

sub process_desc_item {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_block_name = $chooser->{block_name};
    my $position_chooser = $chooser->{position}{$chooser_block_name};
    my $item = $chooser->{list}{$chooser_block_name}[$position_chooser];

    if (!defined $item) {
        return [];
    }

    my $text = $item->get_desc(); 
    my $area = $interface->{looting}{desc_item}{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $text_frame_array = Interface::Utils::get_frame($text_array);

    return $text_frame_array;
}

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'craft';

    my $craft_array = init_craft($interface->{craft});
    my $main_array = $interface->{data_print};

    my $bag_array = process_bag($interface);
    my $craft_items_array = process_craft_items($interface);
    my $desc_item = [];#process_desc_item($interface);

    my $offset_bag = [
        $interface->{inv}{bag}{size}[$LT][$Y],
        $interface->{inv}{bag}{size}[$LT][$X]
    ];
    my $offset_craft_items = [
        $interface->{craft}{place}{size}[$LT][$Y],
        $interface->{craft}{place}{size}[$LT][$X]
    ];
    my $offset_desc_item = [
        $interface->{craft}{desc_craft}{size}[$LT][$Y],
        $interface->{craft}{desc_craft}{size}[$LT][$X]
    ];
    my $offset_craft = [
        $interface->{craft}{size}[$LT][$Y],
        $interface->{craft}{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($craft_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($craft_array, $craft_items_array, $offset_craft_items);
    #Interface::Utils::overlay_arrays_simple($craft_array, $desc_item, $offset_desc_item);

    Interface::Utils::overlay_arrays_simple($main_array, $craft_array, $offset_craft);
}


sub init_craft {
    my $craft = shift;

    my $craft_array = [];

    my $y_bound_craft = $craft->{size}[$RD][$Y];
    my $x_bound_craft = $craft->{size}[$RD][$X];

    my $y_bound_bag = $craft->{bag}{size}[$RD][$Y];
    my $x_bound_bag = $craft->{bag}{size}[$RD][$X];

    for my $y (0 .. $y_bound_craft - 1) {
        for my $x (0 .. $x_bound_craft - 1) {
            $craft_array->[$y][$x]{symbol} = ' ';
            $craft_array->[$y][$x]{color} = '';
        }
    }

    return $craft_array;
}

1;
