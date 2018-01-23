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

    my $bag = $interface->get_craft_obj->get_inv_bag();
    my $items_list = $bag->get_all_items();

    my $area = $interface->get_craft_bag->{size};
    my $size_area = Interface::Utils::get_size($area);
    my $bag_array = Interface::Utils::init_array($size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{craft_bag} = $items_list;
    my $chooser_position = $chooser->get_position('craft_bag');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$items_list);
    $chooser->set_position('craft_bag', $chooser_position);

    my $color_chooser = 'on_green';
    if ($chooser->{block_name} ne 'craft_bag') {
        $chooser_position = 999;
    }
    my @items_list_name = map {$_->{item}->get_name() . ' (' . $_->{count} . ')'} @$items_list;

    my $args = {
        list => \@items_list_name,
        array => $bag_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => $color_chooser,
    };
    $bag_array = Interface::Utils::list_to_array_symbols($args);
    my $title = Language::get_title_block('inv_bag');
    my $bag_frame_array = Interface::Utils::get_frame($bag_array, $title);

    return $bag_frame_array;
}

sub process_craft_place {
    my $interface = shift;

    my $area = $interface->get_craft_place->{size};
    my $size_area = Interface::Utils::get_size($area);
    my $craft_items_array = Interface::Utils::init_array($size_area);

    my $bag = $interface->get_craft_obj->get_craft_place_bag();
    my $items_in_place_list = $bag->get_all_items();

    my @list_items_name = map {$_->{item}->get_name() . ' (' . $_->{count} . ')'} @$items_in_place_list;

    my $chooser = $interface->{chooser};
    $chooser->{list}{craft_place} = $items_in_place_list;
    my $chooser_position = $chooser->get_position('craft_place');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$items_in_place_list);
    $chooser->set_position('craft_place', $chooser_position);

    if ($chooser->{block_name} eq 'craft_bag') {
        my $craft = $interface->get_craft_obj();
        my $list_items = [];
        my $bag = $craft->get_inv_bag();
        $list_items = $bag->get_all_items();
        if (scalar @$list_items) {
            $chooser_position = 999;
        }
        else {
            $chooser->right();
        }
    } elsif ($chooser->{block_name} eq 'craft_result') {
        my $craft = $interface->get_craft_obj();
        my $list_items = [];
        $list_items = $craft->get_craft_result_bag->get_all_items();
        if (scalar @$list_items) {
            $chooser_position = 999;
        }
        else {
            $chooser->left();
        }
    }

    if (
        $chooser->{block_name} eq 'craft_place'
        and !@list_items_name
    ) {
        $chooser->left();
    }
    my $args = {
        list => \@list_items_name,
        array => $craft_items_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => 'on_green',
    };

    $craft_items_array = Interface::Utils::list_to_array_symbols($args);
    my $title = Language::get_title_block('craft_place');
    my $craft_items_frame_array = Interface::Utils::get_frame($craft_items_array, $title);

    return $craft_items_frame_array;
}

sub process_result_item {
    my $interface = shift;

    my $area = $interface->get_craft_result->{size};
    my $size_area = Interface::Utils::get_size($area);
    my $result_array = Interface::Utils::init_array($size_area);

    my $items_list = $interface->get_craft_obj->create_preview();
    my $chooser = $interface->{chooser};
    $chooser->{list}{craft_result} = $items_list;
    my $chooser_position = $chooser->get_position('craft_result');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$items_list);
    $chooser->set_position('craft_result', $chooser_position);

    my @color_chooser = qw/blue/;
    if ($chooser->{block_name} eq 'craft_result') {
        push(@color_chooser, 'on_green');
    }
    my @items_list_name = map {$_->{item}->get_name() . ' (' . $_->{count} . ')'} @$items_list;
    my $args = {
        list => \@items_list_name,
        array => $result_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => join(',', @color_chooser),
    };
    $result_array = Interface::Utils::list_to_array_symbols($args);
    my $title = Language::get_title_block('craft_result');
    my $result_frame_array = Interface::Utils::get_frame($result_array, $title);

    return $result_frame_array;
}

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'craft';

    my $craft_array = init_craft($interface->{craft});
    my $main_array = $interface->{data_print};

    my $craft_items_array = process_craft_place($interface);
    my $bag_array = process_bag($interface);
    my $result_item = process_result_item($interface);

    my $offset_bag = [
        $interface->get_craft_bag->{size}[$LT][$Y] - $interface->get_craft->{size}[$LT][$Y],
        $interface->get_craft_bag->{size}[$LT][$X] - $interface->get_craft->{size}[$LT][$X]
    ];
    my $offset_craft_items = [
        $interface->get_craft_place->{size}[$LT][$Y] - $interface->get_craft->{size}[$LT][$Y],
        $interface->get_craft_place->{size}[$LT][$X] - $interface->get_craft->{size}[$LT][$X]
    ];
    my $offset_result_item = [
        $interface->get_craft_result->{size}[$LT][$Y] - $interface->get_craft->{size}[$LT][$Y],
        $interface->get_craft_result->{size}[$LT][$X] - $interface->get_craft->{size}[$LT][$X]
    ];
    my $offset_craft = [
        $interface->get_craft->{size}[$LT][$Y],
        $interface->get_craft->{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($craft_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($craft_array, $craft_items_array, $offset_craft_items);
    Interface::Utils::overlay_arrays_simple($craft_array, $result_item, $offset_result_item);

    Interface::Utils::overlay_arrays_simple($main_array, $craft_array, $offset_craft);
}


sub init_craft {
    my $craft = shift;

    my $craft_array = [];

    my $y_bound_craft = $craft->{size}[$RD][$Y];
    my $x_bound_craft = $craft->{size}[$RD][$X];

    for my $y (0 .. $y_bound_craft - 1) {
        for my $x (0 .. $x_bound_craft - 1) {
            $craft_array->[$y][$x]{symbol} = ' ';
            $craft_array->[$y][$x]{color} = '';
        }
    }

    return $craft_array;
}

1;
