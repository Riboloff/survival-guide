package Interface::Inv;

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

    my $bag_array = Interface::Utils::init_array($area, $size_area);

    my $chooser = $interface->{chooser};
    $chooser->{list}{inv} = $list_items;
    my $chooser_position = 0;
    if ($chooser->{block_name} eq 'inv') {
        $chooser_position = $chooser->get_position('inv');
    }

    my @list_items_name = map {$_->get_name} @$list_items;
    my $args = {
        list => \@list_items_name,
        array => $bag_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
    };
    $bag_array = Interface::Utils::list_to_array_symbols($args);
    my $bag_frame_array = Interface::Utils::get_frame($bag_array);

    return $bag_frame_array;
}

sub process_harness {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $inv = $interface->{inv}{obj};

    my $area = $interface->{inv}{harness}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $harness = $inv->get_harness();
    my $harness_array = Interface::Utils::init_array($area, $size_area);

    my $list_harness = [];

    my @sort_keys_harness = sort {
                                $harness->{$a}{number} <=> $harness->{$b}{number}
                            } keys %$harness;

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
    $harness_array = Interface::Utils::list_to_array_symbols($args);
    my $harness_frame_array = Interface::Utils::get_frame($harness_array);
    return $harness_frame_array;
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

    $interface->{main_block_show} = 'inv';
    my $inv = $interface->{inv}{obj};

    my $inv_array = init_inv($interface->{inv});
    my $main_array = $interface->{data_print};

    my $bag_array = process_bag($interface);
    my $harness_array = process_harness($interface);
    my $desc_array = process_desc_item($interface);

    my $offset_bag = [
        $interface->{inv}{bag}{size}[$LT][$Y],
        $interface->{inv}{bag}{size}[$LT][$X]
    ];
    my $offset_harness = [
        $interface->{inv}{harness}{size}[$LT][$Y],
        $interface->{inv}{harness}{size}[$LT][$X]
    ];
    my $offset_desc_item = [
        $interface->{inv}{desc_item}{size}[$LT][$Y],
        $interface->{inv}{desc_item}{size}[$LT][$X]
    ];
    my $offset = [
        $interface->{inv}{size}[$LT][$Y],
        $interface->{inv}{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($inv_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($inv_array, $harness_array, $offset_harness);
    Interface::Utils::overlay_arrays_simple($inv_array, $desc_array, $offset_desc_item);

    Interface::Utils::overlay_arrays_simple($main_array, $inv_array, $offset);
}


sub init_inv {
    my $inv = shift;

    my $inv_array = [];

    my $y_bound_inv = $inv->{size}->[$RD][$Y];
    my $x_bound_inv = $inv->{size}->[$RD][$X];
    my $y_bound_bag = $inv->{bag}{size}->[$RD][$Y];
    my $x_bound_bag = $inv->{bag}{size}->[$RD][$X];

    for my $y (0 .. $y_bound_inv) {
        for my $x (0 .. $x_bound_inv - 1) {
            $inv_array->[$y][$x]->{symbol} = ' ';
            $inv_array->[$y][$x]->{color} = '';
            # if ($x == $x_bound_bag) {
            #     $inv_array->[$y][$x]->{symbol} = '║';
            #     #$inv_array->[$y][$x]->{symbol} = ' ';
            #     $inv_array->[$y][$x]->{color} = '';
            # }
            # if ($y == $y_bound_inv) {
            #     $inv_array->[$y][$x]{symbol} = '─';
            #     $inv_array->[$y][$x]{color} = '';
            # }
            # if ($x == $x_bound_bag and $y == $y_bound_inv) {
            #     $inv_array->[$y][$x]{symbol} = '┴';
            #     $inv_array->[$y][$x]{color} = '';
            # }
        }
    }

    return $inv_array;
}

1;
