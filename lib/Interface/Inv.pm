package Interface::Inv;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;
use Storable qw(dclone);
use utf8;

sub process_bag {
    my $interface = shift;

    my $main_array = $interface->{data_print};

    my $bag_array = dclone($interface->get_inv_bag->{array_area});

    my $chooser = $interface->{chooser};
    my $chooser_position = $chooser->get_position('inv_bag');

    my $bag = $interface->get_inv_obj->get_bag();
    my $items_list = $bag->get_all_items();
    $chooser_position = Utils::clamp($chooser_position, 0, $#$items_list);
    $chooser->set_position('inv_bag', $chooser_position);
    if ($chooser->{block_name} ne 'inv_bag') {
        $chooser_position = 999;
    }
    $chooser->{list}{inv_bag} = $items_list;
    $chooser->{bag}{inv_bag} = $bag;
    my @list_items_name = map {$_->{item}->get_name() . ' (' . $_->{count} . ')'} @$items_list;
    my $args = {
        list => \@list_items_name,
        array => $bag_array,
        chooser_position => $chooser_position,
        size_area_frame => $interface->get_inv_bag->{size_area_frame},
    };
    $bag_array = Interface::Utils::list_to_array_symbols_frame($args);

    return $bag_array;
}

sub process_equipment {
    my $interface = shift;

    my $main_array = $interface->{data_print};

    my $area = $interface->get_equipment->{size};
    my $size_area = Interface::Utils::get_size($area);
    my $inv = $interface->get_inv_obj();
    my $equipment = $inv->get_equipment();
    my $equipment_array = Interface::Utils::init_array($size_area);

    my $list_equipment = [];

    my @sort_keys_equipment = sort {
                                $equipment->{$a}{number} <=> $equipment->{$b}{number}
                            } keys %$equipment;

    my $items = [];                        
    for my $body_p (@sort_keys_equipment) {
        my $name = $equipment->{$body_p}{name};
        my @items_slot = @{$equipment->{$body_p}{bag}->get_all_items};
        my @list_items_name = map { $_->{item}->get_name . ' (' . $_->{count}. ')'} @items_slot;

        push(@$list_equipment, @list_items_name);
        push(@$items, @items_slot);
    }
    my $chooser = $interface->{chooser};
    my $chooser_position = $chooser->get_position('equipment');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$list_equipment);
    $chooser->set_position('equipment', $chooser_position);
    if ($chooser->{block_name} ne 'equipment') {
        $chooser_position = 999;
    }
    my $bag = $interface->get_inv_obj->get_equipment();
    $chooser->{list}{equipment} = $items;
    $chooser->{bag}{equipment} = $bag;

    my $args = {
        list => $list_equipment,
        array => $equipment_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
    };
    my $title = Language::get_title_block('equipment');
    $equipment_array = Interface::Utils::list_to_array_symbols($args);
    my $equipment_frame_array = Interface::Utils::get_frame($equipment_array, $title);
    return $equipment_frame_array;
}

sub process_desc_item {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_block_name = $chooser->{block_name};
    my $position_chooser = $chooser->{position}{$chooser_block_name};
    #my $item = $chooser->{list}{$chooser_block_name}[$position_chooser]{item};
    my $list = $chooser->{list}{$chooser_block_name}[$position_chooser];
    my $item;
    if (ref $list eq 'HASH' and exists $list->{item}) {
        $item = $list->{item};
    }

    if (!defined $item) {
        return [];
    }

    my $text = $item->get_desc();
    my $area = $interface->get_inv_desc_item->{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('desc_item');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);

    return $text_frame_array;
}

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'inv';
    my $inv = $interface->get_inv_obj();

    my $inv_array = init_inv($interface->get_inv);
    my $main_array = $interface->{data_print};

    my $bag_array = process_bag($interface);
    my $equipment_array = process_equipment($interface);
    my $desc_array = process_desc_item($interface);

    my $offset_bag = [
        $interface->get_inv_bag->{size}[$LT][$Y],
        $interface->get_inv_bag->{size}[$LT][$X]
    ];
    my $offset_equipment = [
        $interface->get_equipment->{size}[$LT][$Y],
        $interface->get_equipment->{size}[$LT][$X]
    ];
    my $offset_desc_item = [
        $interface->get_inv_desc_item->{size}[$LT][$Y],
        $interface->get_inv_desc_item->{size}[$LT][$X]
    ];
    my $offset = [
        $interface->get_inv->{size}[$LT][$Y],
        $interface->get_inv->{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($inv_array, $bag_array, $offset_bag);
    Interface::Utils::overlay_arrays_simple($inv_array, $equipment_array, $offset_equipment);
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
        }
    }

    return $inv_array;
}

1;
