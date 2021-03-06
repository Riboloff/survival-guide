package Interface::Size;

use strict;
use warnings;

use Consts;
use List::Util qw(min);
use Logger qw(dmp);
use Term::ReadKey;

sub is_change_term_size {
    my ($wchar_current, $hchar_current) = GetTerminalSize();

    $wchar_current--;
    $hchar_current--;
    if (   $Consts::size_term->[$X] != $wchar_current
        or $Consts::size_term->[$Y] != $hchar_current
    ) {
         $Consts::size_term->[$X] = $wchar_current;
         $Consts::size_term->[$Y] = $hchar_current;

         return 1;
    }

    return;
}

sub get_size_interface {
    if ($size_term->[$Y] <= 25) {
        die "Слишком мелкий экран по высоте. 25Х80 занков будет норм \n";
    } 
    if ($size_term->[$X] <= 80) {
        die "Слишком мелкий экран по ширене. 25Х80 занков будет норм \n";
    } 
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
        $size_area_map->[$RD][$X]
    ];
    $size_area_list_obj->[$RD] = [
        int( $size_area_map->[$RD][$Y] / 2 ) ,
        int( ($size_interface->[$RD][$X] - $size_area_map->[$RD][$X] + 1) / 2) + $size_area_map->[$RD][$X] - 1
    ];

    return $size_area_list_obj;
}

sub get_size_area_look {
    my $size_object = shift;
    my $size_needs = shift;

    my $size_area_look = [];
    $size_area_look->[$LT] = [
            $size_object->[$RD][$Y],
            $size_object->[$LT][$X],
        ],
    $size_area_look->[$RD] = [
            $size_needs->[$LT][$Y],
            $size_needs->[$RD][$X],
        ],

    return $size_area_look;
}


sub get_size_area_text {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_text = [];

    $size_area_text->[$LT] = [
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
        [2, 0],
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

sub get_size_area_equipment {
    my $size_interface = shift;
    my $size_area_inv  = shift;
    my $size_area_bag  = shift;

    my $size_area_equipment = [];

    $size_area_equipment->[$LT] = [
        $size_area_bag->[$LT][$Y],
        $size_area_bag->[$RD][$X]
    ];
    my $size_bag = Interface::Utils::get_size($size_area_bag);
    $size_area_equipment->[$RD] = [
        $size_area_bag->[$RD][$Y],
        $size_area_bag->[$RD][$X] + $size_bag->[$X],
    ];

    return $size_area_equipment;
}

sub get_size_area_loot_list {
    my $size_interface = shift;
    my $size_area_bag  = shift;

    my $size_area_loot_list = [];

    $size_area_loot_list->[$LT] = [
        $size_area_bag->[$LT][$Y],
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
        $size_area_loot_list->[$RD][$X]
    ];
    $size_area_desc_item->[$RD] = [
        int  $size_area_looting->[$RD][$Y] / 2,
        $size_area_looting->[$RD][$X],
    ];

    return $size_area_desc_item;
}

sub get_size_area_inv_info {
    my $size_area_desc_item = shift;
    my $size_area_looting  = shift;

    my $size_area_inv_info = [];

    $size_area_inv_info->[$LT] = [
        $size_area_desc_item->[$RD][$Y],
        $size_area_desc_item->[$LT][$X]
    ];
    $size_area_inv_info->[$RD] = [
        $size_area_looting->[$RD][$Y],
        $size_area_looting->[$RD][$X],
    ];

    return $size_area_inv_info;
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
        $size_area_text->[$RD][$X],
    
    ];
    $size_area_needs->[$RD] = [
        $size_interface->[$RD][$Y],
        $size_interface->[$RD][$X]
    ];

    return $size_area_needs;
}

sub get_size_area_head {
    my $size_area_map = shift;

    my $size_area_head = [];

    $size_area_head->[$LT] = [
        0, 0,
    ];
    $size_area_head->[$RD] = [
        $size_area_map->[$LT][$Y] - 1,
        $size_area_map->[$RD][$X],
    ];

    return $size_area_head;
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
    my $size_area_equipment = get_size_area_equipment($size_interface, $size_area_inv, $size_area_bag);
    my $size_area_loot_list = get_size_area_loot_list($size_interface, $size_area_bag);
    my $size_area_looting = get_size_area_looting($size_area_inv);
    my $size_area_desc_item = get_size_area_desc_item($size_area_looting, $size_area_loot_list);
    my $size_area_inv_info = get_size_area_inv_info($size_area_desc_item, $size_area_looting);
    my $size_area_needs = get_size_area_needs($size_interface, $size_area_text);
    my $size_area_head = get_size_area_head($size_area_map);
    my $size_area_char = $size_area_inv;
    my $size_area_char_dis = $size_area_bag;
    my $size_area_char_empty = $size_area_equipment;
    my $size_area_char_desc = $size_area_desc_item;  
    my $size_area_console = $size_area_inv;
    my $size_area_commands = $size_area_objects;
    my $size_area_dir = $size_area_list_obj;
    my $size_area_file = $size_area_action;
    my $size_area_look = get_size_area_look($size_area_objects, $size_area_needs);

    $Interface->{size} = $size_interface;
    $Interface->{map}{size} = $size_area_map;
    $Interface->{text}{size} = $size_area_text;
    $Interface->{objects}{size} = $size_area_objects;
    $Interface->{objects}{sub_block}{list_obj}->{size} = $size_area_list_obj;
    $Interface->{objects}{sub_block}{action}->{size} = $size_area_action;

    $Interface->{inv}{size} = $size_area_inv;
    $Interface->{inv}{sub_block}{inv_bag}{size} = $size_area_bag;
    $Interface->{inv}{sub_block}{equipment}{size} = $size_area_equipment;
    $Interface->{inv}{sub_block}{desc_item}{size} = $size_area_desc_item;
    $Interface->{inv}{sub_block}{inv_info}{size} = $size_area_inv_info;

    $Interface->{char}{size} = $size_area_char;
    $Interface->{char}{sub_block}{char_dis}{size}   = $size_area_char_dis;
    $Interface->{char}{sub_block}{char_empty}{size} = $size_area_char_empty;
    $Interface->{char}{sub_block}{char_desc}{size}  = $size_area_char_desc;

    $Interface->{looting}{size} = $size_area_looting;
    $Interface->{looting}{sub_block}{looting_bag}{size} = $size_area_bag;
    $Interface->{looting}{sub_block}{loot_list}{size} = $size_area_loot_list;
    $Interface->{looting}{sub_block}{desc_item}{size} = $size_area_desc_item;

    $Interface->{craft}{size} = $size_area_looting;
    $Interface->{craft}{sub_block}{bag}{size} = $size_area_bag;
    $Interface->{craft}{sub_block}{place}{size} = $size_area_loot_list;
    $Interface->{craft}{sub_block}{result}{size} = $size_area_desc_item;

    $Interface->{needs}{size} = $size_area_needs;
    $Interface->{head}{size} = $size_area_head;

    $Interface->{look}{size} = $size_area_look;

    $Interface->{console}{size} = $size_area_console;
    $Interface->{console}{sub_block}{text}{size} = $size_area_console;

    $Interface->{commands}{size} = $size_area_commands;
    $Interface->{commands}{sub_block}{dir}{size} = $size_area_dir;
    $Interface->{commands}{sub_block}{file}{size} = $size_area_file;

    return;
}


1;
