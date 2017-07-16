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
    $chooser->{list}{craft_bag} = $list_items;
    my $chooser_position = $chooser->get_position('craft_bag');
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

sub process_craft_place {
    my $interface = shift;

    my $area = $interface->{craft}{place}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $craft_items_array = Interface::Utils::init_array($area, $size_area);

    my $craft = $interface->{craft}{obj};
    my $craft_items_list = $craft->get_list_items();
    my @craft_items_name_list = map {$_->get_name} @$craft_items_list;

    my $chooser = $interface->{chooser};
    $chooser->{list}{craft_place} = $craft_items_list;
    my $chooser_position = $chooser->get_position('craft_place');
    $chooser_position = Utils::clamp($chooser_position, 0, $#craft_items_name_list);
    $chooser->set_position('craft_place', $chooser_position);

    if ($chooser->{block_name} ne 'craft_place') {
        my $craft = $interface->{craft}{obj};
        my $list_items = [];
        if ($chooser->{block_name} eq 'craft_bag') {
            my $bag = $craft->get_bag;
            $list_items = $bag->{'items'};
        } elsif ($chooser->{block_name} eq 'craft_result') {
            $list_items = $craft->get_craft_result();
        }
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

sub process_result_item {
    my $interface = shift;


    my $craft = $interface->{craft}{obj};
    my $items = $craft->create_preview() || [];
    my $area = $interface->{craft}{result_item}{size};
    my $size_area = Interface::Utils::get_size($area);
    my $result_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{craft_result} = $items;
    my $chooser_position = $chooser->get_position('craft_result');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$items);
    $chooser->set_position('craft_result', $chooser_position);

    my @color_chooser = qw/blue/;
    if ($chooser->{block_name} eq 'craft_result') {
        push(@color_chooser, 'on_green');
    }
    my @items_name = map {$_->get_name} @$items;
    my $args = {
        list => \@items_name,
        array => $result_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => join(',', @color_chooser),
    };
    $result_array = Interface::Utils::list_to_array_symbols($args);
    my $result_frame_array = Interface::Utils::get_frame($result_array);

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
        $interface->{craft}{bag}{size}[$LT][$Y],
        $interface->{craft}{bag}{size}[$LT][$X]
    ];
    my $offset_craft_items = [
        $interface->{craft}{place}{size}[$LT][$Y],
        $interface->{craft}{place}{size}[$LT][$X]
    ];
    my $offset_craft = [
        $interface->{craft}{size}[$LT][$Y],
        $interface->{craft}{size}[$LT][$X]
    ];
    my $offset_result_item = [
        $interface->{craft}{result_item}{size}[$LT][$Y],
        $interface->{craft}{result_item}{size}[$LT][$X]
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
