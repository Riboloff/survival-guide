package Interface::Looting;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;
use Utils;

sub process_bag {
    my $interface = shift;

    my $inv = $interface->{inv}{obj};

    my $list_items = $inv->get_all_items_bag();
    my $area = $interface->{looting}{bag}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $bag_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{bag} = $list_items;
    my $chooser_position = $chooser->get_position('bag');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$list_items);
    $chooser->set_position('bag', $chooser_position);

    my $color_chooser = 'on_green';
    if ($chooser->{block_name} ne 'bag') {
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
    my $title = Language::get_title_block('bag');
    my $bag_frame_array = Interface::Utils::get_frame($bag_array, $title);

    return $bag_frame_array;
}

sub process_loot_list {
    my $interface = shift;

    my $area = $interface->{looting}{loot_list}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $loot_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    my $position_list_obj = $chooser->{position}{list_obj};
    my $container = $chooser->{list}{list_obj}[$position_list_obj];
    my $items = $container->get_items();
    my @loots = map {$_->get_name()} @$items;

    $chooser->{list}{loot_list} = $items;

    my $chooser_position = $chooser->get_position('loot_list');
    $chooser_position = Utils::clamp($chooser_position, 0, $#loots);
    $chooser->set_position('loot_list', $chooser_position);

    my $color_chooser = 'on_green';

    if ($chooser->{block_name} ne 'loot_list') {
        if (scalar @{$interface->{inv}{obj}->get_all_items_bag()}) {
            $chooser_position = 999;
        } else {
            $chooser->{block_name} = 'loot_list';
        }
    } 
    if (
        $chooser->{block_name} eq 'loot_list'
        and !@loots
    ) {
        $chooser->{block_name} = 'bag';
    }
    my $args = {
        list => \@loots,
        array => $loot_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => $color_chooser,
    };

    my $title = Language::get_title_block('loot_list');
    $loot_array = Interface::Utils::list_to_array_symbols($args);
    my $loot_frame_array = Interface::Utils::get_frame($loot_array, $title);

    return $loot_frame_array;
}

sub process_desc_item {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_block_name = $chooser->{block_name};
    my $position_chooser = $chooser->{position}{$chooser_block_name};
    my $item = $chooser->{list}{$chooser_block_name}[$position_chooser];

    if (!defined $item) {
        #TODO: Пропадает блок целиком вместе с рамкой
        return [];
    }

    my $text = $item->get_desc(); 
    my $area = $interface->{looting}{desc_item}{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('desc_item');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);

    return $text_frame_array;
}

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'looting';

    my $looting_array = init_looting($interface->{looting});
    my $main_array = $interface->{data_print};

    my $loot_list_array = process_loot_list($interface);
    my $bag_array = process_bag($interface);
    my $desc_item = process_desc_item($interface);

    my $offset_bag = [
        $interface->{inv}{bag}{size}[$LT][$Y],
        $interface->{inv}{bag}{size}[$LT][$X]
    ];
    my $offset_loot_list = [
        $interface->{looting}{loot_list}{size}[$LT][$Y],
        $interface->{looting}{loot_list}{size}[$LT][$X]
    ];
    my $offset_desc_item = [
        $interface->{looting}{desc_item}{size}[$LT][$Y],
        $interface->{looting}{desc_item}{size}[$LT][$X]
    ];
    my $offset_looting = [
        $interface->{looting}{size}[$LT][$Y],
        $interface->{looting}{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($looting_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($looting_array, $loot_list_array, $offset_loot_list);
    Interface::Utils::overlay_arrays_simple($looting_array, $desc_item, $offset_desc_item);

    Interface::Utils::overlay_arrays_simple($main_array, $looting_array, $offset_looting);
}


sub init_looting {
    my $looting = shift;

    my $looting_array = [];

    my $y_bound_looting = $looting->{size}[$RD][$Y];
    my $x_bound_looting = $looting->{size}[$RD][$X];

    my $y_bound_bag = $looting->{bag}{size}[$RD][$Y];
    my $x_bound_bag = $looting->{bag}{size}[$RD][$X];

    for my $y (0 .. $y_bound_looting - 1) {
        for my $x (0 .. $x_bound_looting - 1) {
            $looting_array->[$y][$x]{symbol} = ' ';
            $looting_array->[$y][$x]{color} = '';
        }
    }

    return $looting_array;
}

1;
