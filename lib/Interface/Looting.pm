package Interface::Looting;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;

sub process_bag {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $inv = $interface->{inv}{obj};

    my $list_items = $inv->get_all_items_bag();
    my $area = $interface->{inv}{bag}{size};
    my $size_area = Interface::Utils::get_size($area);
    dmp($size_area);

    my $bag_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{inv} = $list_items;
    my $chooser_position = 0;
    if ($chooser->{block_name} eq 'inv') {
        $chooser_position = $chooser->get_position();
    }

    my $args = {
        list => $list_items,
        array => $bag_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
    };
    $bag_array = Interface::Utils::list_to_array_symbols($args);

    return $bag_array;
}

sub process_loot_list {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $inv = $interface->{inv}{obj};

    my $area = $interface->{looting}{loot_list}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $loot_array = Interface::Utils::init_array($area, $size_area);

    my $loot = [];
=we
    for my $body_p (@sort_keys_harness) {
        my $name = $harness->{$body_p}{name};
        my $items = join(', ', @{$harness->{$body_p}{items}});
        my $number = $harness->{$body_p}{number};

        my $str = join(' | ', ($number, $name, $items));
        push(@$list_harness, $str);
    }

    my $args = {
        list => $list_harness,
        array => $harness_array,
        chooser_position => 999,
        size_area => $size_area,
    };
    $loot_array = Interface::Utils::list_to_array_symbols($args);
=cut

    return $loot_array;
}

sub process_block {
    my $interface = shift;

    my $looting_array = init_looting($interface->{looting});
    my $main_array = $interface->{data_print};

    my $bag_array = process_bag($interface);
    my $loot_list_array = process_loot_list($interface);

    my $offset_bag = [
        $interface->{inv}{bag}{size}[$LT][$Y],
        $interface->{inv}{bag}{size}[$LT][$X]
    ];
    my $offset_loot_list = [
        $interface->{looting}{loot_list}{size}[$LT][$Y],
        $interface->{looting}{loot_list}{size}[$LT][$X]
    ];
    my $offset = [
        $interface->{looting}{size}[$LT][$Y],
        $interface->{looting}{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($looting_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($looting_array, $loot_list_array, $offset_loot_list);

    Interface::Utils::overlay_arrays_simple($main_array, $looting_array, $offset);
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
            if ($x == $x_bound_bag) {
                $looting_array->[$y][$x]{symbol} = 'ǁ';
                $looting_array->[$y][$x]{color} = '';
            }
        }
    }

    return $looting_array;
}

1;
