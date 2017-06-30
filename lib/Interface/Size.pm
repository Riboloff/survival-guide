package Interface::Size;

use strict;
use warnings;

use Consts;
use List::Util qw(min);
use Logger qw(dmp);

sub get_size_interface {
    return [
        [0, 0],
        [$size_term->[$Y], $size_term->[$X]]
    ];
}

sub get_size_area_action {
    my $size_interface = shift;
    my $size_area_list_obj = shift;

    my $size_area_action = [];

    $size_area_action->[$LT] = [
        0,
        #$size_area_list_obj->[$RD][$X] + 1
        $size_area_list_obj->[$RD][$X]
    ];
    $size_area_action->[$RD] = [
        $size_area_list_obj->[$RD][$Y],
        $size_interface->[$RD][$X]
    ];

    return $size_area_action;
}

sub get_size_area_objects {
    my $size_area_list_obj = shift;
    my $size_area_action = shift;

    my $size_area_objects = [];

    $size_area_objects->[$LT] = [
        $size_area_list_obj->[$LT][$Y],
        $size_area_list_obj->[$LT][$X],

    ];
    $size_area_objects->[$RD] = [
        $size_area_action->[$RD][$Y],
        $size_area_action->[$RD][$X],
    ];

    return $size_area_objects;
}

sub get_size_area_list_obj {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_list_obj = [];


    $size_area_list_obj->[$LT] = [
        0,
        #$size_area_map->[$RD][$X] + 1
        $size_area_map->[$RD][$X]
    ];
    $size_area_list_obj->[$RD] = [
        $size_area_map->[$RD][$Y],
        int( ($size_interface->[$RD][$X] - $size_area_map->[$RD][$X]+1) / 2) + $size_area_map->[$RD][$X] - 1
    ];

    return $size_area_list_obj;
}


sub get_size_area_text {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_text = [];

    $size_area_text->[$LT] = [
        #$size_area_map->[$RD][$Y] + 1,
        $size_area_map->[$RD][$Y],
        0
    ];
    $size_area_text->[$RD] = [
        $size_interface->[$RD][$Y],
        $size_area_map->[$RD][$X]
    ];

    return $size_area_text;
}

sub get_size_area_map {
    my $size_interface = shift;

    return [
        [0,0],
        [
            int($size_interface->[$RD][$Y] * 0.7),
            int($size_interface->[$RD][$X] * 0.7)
        ]
    ];
}

sub get_size_area_inv {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_inv = [];

    $size_area_inv->[$LT] = [
        $size_area_map->[$LT][$Y],
        $size_area_map->[$LT][$X]
    ];
    $size_area_inv->[$RD] = [
        $size_area_map->[$RD][$Y],
        $size_area_map->[$RD][$X]
    ];

    return $size_area_inv;
}

sub get_size_area_bag {
    my $size_interface = shift;
    my $size_area_inv  = shift;

    my $size_area_bag = [];

    $size_area_bag->[$LT] = [
        $size_area_inv->[$LT][$Y],
        $size_area_inv->[$LT][$X]
    ];
    $size_area_bag->[$RD] = [
        $size_area_inv->[$RD][$Y],
        int( $size_area_inv->[$RD][$X] / 3)
    ];

    return $size_area_bag;
}

sub get_size_area_harness {
    my $size_interface = shift;
    my $size_area_inv  = shift;
    my $size_area_bag  = shift;

    my $size_area_harness = [];

    $size_area_harness->[$LT] = [
        $size_area_bag->[$LT][$Y],
        #$size_area_bag->[$RD][$X]+1
        $size_area_bag->[$RD][$X]
    ];
    my $size_bag = Interface::Utils::get_size($size_area_bag);
    $size_area_harness->[$RD] = [
        $size_area_bag->[$RD][$Y],
        $size_area_bag->[$RD][$X] + $size_bag->[$X],
    ];

    return $size_area_harness;
}

sub get_size_area_loot_list {
    my $size_interface = shift;
    my $size_area_bag  = shift;

    my $size_area_loot_list = [];

    $size_area_loot_list->[$LT] = [
        $size_area_bag->[$LT][$Y],
        #$size_area_bag->[$RD][$X]+1
        $size_area_bag->[$RD][$X]
    ];
    my $size_bag = Interface::Utils::get_size($size_area_bag);
    $size_area_loot_list->[$RD] = [
        $size_area_bag->[$RD][$Y],
        $size_area_bag->[$RD][$X] + $size_bag->[$X],
    ];

    return $size_area_loot_list;
}

sub get_size_area_desc_item {
    my $size_area_looting = shift;
    my $size_area_loot_list  = shift;

    my $size_area_desc_item = [];

    $size_area_desc_item->[$LT] = [
        $size_area_loot_list->[$LT][$Y],
        #$size_area_loot_list->[$RD][$X]+1
        $size_area_loot_list->[$RD][$X]
    ];
    $size_area_desc_item->[$RD] = [
        $size_area_looting->[$RD][$Y],
        $size_area_looting->[$RD][$X],
    ];

    return $size_area_desc_item;
}

sub get_size_area_looting {
    my $size_inv = shift;

    my $size_area_looting = [];

    $size_area_looting->[$LT] = [
        $size_inv->[$LT][$Y],
        $size_inv->[$LT][$X]
    ];
    $size_area_looting->[$RD] = [
        $size_inv->[$RD][$Y],
        $size_inv->[$RD][$X]
    ];

    return $size_area_looting;
}

sub get_size_area_needs {
    my $size_interface = shift;
    my $size_area_text = shift;

    my $size_area_needs = [];

    $size_area_needs->[$LT] = [
        $size_area_text->[$LT][$Y],
        #$size_area_text->[$RD][$X] + 1,
        $size_area_text->[$RD][$X],
    
    ];
    $size_area_needs->[$RD] = [
        $size_interface->[$RD][$Y],
        $size_interface->[$RD][$X]
    ];

    return $size_area_needs;
}

sub set_size_all_block {
    my $Interface = shift;

    my $size_interface = get_size_interface();
    my $size_area_map = get_size_area_map($size_interface);
    my $size_area_text = get_size_area_text($size_interface, $size_area_map),
    my $size_area_list_obj = get_size_area_list_obj($size_interface, $size_area_map);
    my $size_area_action = get_size_area_action($size_interface, $size_area_list_obj);
    my $size_area_objects = get_size_area_objects($size_area_list_obj, $size_area_action);
    my $size_area_inv = get_size_area_inv($size_interface, $size_area_map);
    my $size_area_bag = get_size_area_bag($size_interface, $size_area_inv);
    my $size_area_harness = get_size_area_harness($size_interface, $size_area_inv, $size_area_bag);
    my $size_area_loot_list = get_size_area_loot_list($size_interface, $size_area_bag);
    my $size_area_looting = get_size_area_looting($size_area_inv);
    my $size_area_desc_item = get_size_area_desc_item($size_area_looting, $size_area_loot_list);
    my $size_area_needs = get_size_area_needs($size_interface, $size_area_text);

    $Interface->{size} = $size_interface;
    $Interface->{map}{size} = $size_area_map;
    $Interface->{text}{size} = $size_area_text;
    $Interface->{objects}{size} = $size_area_objects;
    $Interface->{objects}{list_obj}{size} = $size_area_list_obj;
    $Interface->{objects}{action}{size} = $size_area_action;
    $Interface->{inv}{size} = $size_area_inv;
    $Interface->{inv}{bag}{size} = $size_area_bag;
    $Interface->{inv}{harness}{size} = $size_area_harness;
    $Interface->{inv}{desc_item}{size} = $size_area_desc_item;
    $Interface->{looting}{size} = $size_area_looting;
    $Interface->{looting}{bag}{size} = $size_area_bag;
    $Interface->{looting}{loot_list}{size} = $size_area_loot_list;
    $Interface->{looting}{desc_item}{size} = $size_area_desc_item;
    $Interface->{needs}{size} = $size_area_needs;

    return;
}

1;
