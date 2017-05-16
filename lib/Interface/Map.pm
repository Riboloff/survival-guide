package Interface::Map;

use strict;
use warnings;

use Consts;
use Interface::Utils;
use List::Util qw(min);

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'map';
    my $map = $interface->{map}{obj};
    my $character = $interface->{character};
    my $map_array = $map->get_map_static($character);
    my $main_array = $interface->{data_print};
    my $size_area_map = $interface->{map}{size}[$RD]; 

    if (Interface::Utils::is_object_into_area($size_area_map, $map_array)) {
        Interface::Utils::overlay_arrays_simple($main_array, $map_array, Interface::Utils::get_offset($size_area_map, $map_array));
    } else {
        my $main_hero_coord = $character->{coord};
       
        overlay_bigmap_and_area($main_array, $map_array, $main_hero_coord, $size_area_map);
    }
}

sub overlay_bigmap_and_area {
    my $main_array = shift;
    my $map_array = shift;
    my $main_hero_coord = shift;
    my $size_area_map = shift;

    my $map_center = Interface::Utils::get_center($map_array);
    my $area_center = Interface::Utils::get_center($size_area_map);

    my $top_map = @$map_array;
    my $length_map = @{$map_array->[0]};

    my $length_area = $size_area_map->[$X];
    my $top_area = $size_area_map->[$Y];


    my $diff_y = $area_center->[$Y] - $main_hero_coord->[$Y];
    my $diff_x = $area_center->[$X] - $main_hero_coord->[$X];

    my $offset_y = $diff_y;
    my $offset_x = $diff_x;

    my $bound = $size_area_map;
    if ($area_center->[$Y] - $main_hero_coord->[$Y] > 0) {
        $offset_y = 0;
        $bound->[$Y] = min($size_area_map->[$Y], $top_map);
    }

    if ($area_center->[$X] - $main_hero_coord->[$X] > 0) {
        $offset_x = 0;
        $bound->[$X] = min($size_area_map->[$X], $length_map);
    }

    if (($top_map - $main_hero_coord->[$Y]) <= $area_center->[$Y]) { #Снизу край карты
        $offset_y = $size_area_map->[$Y] - $top_map; #Количество строк вылезло за край вверху.
    }

    if (($length_map - $main_hero_coord->[$X]) <= $area_center->[$X]) { #Справа край карты
        $offset_x = $size_area_map->[$X] - $length_map;
    }

    my $offset = [$offset_y, $offset_x];

    Interface::Utils::clear_area($main_array, $size_area_map);
    overlay_arrays($main_array, $map_array, $offset, $bound); 
}

sub _get_size_area_map {
    my $size_interface = shift;

    return [
        [0,0],
        [
            int($size_interface->[$RD][$Y] * 0.7), 
            int($size_interface->[$RD][$X] * 0.7)
        ]
    ];
}

sub overlay_arrays {
    my $lower_layer = shift;
    my $top_layer = shift;
    my $offset = shift || [0, 0];
    my $size_area_map = shift;

    my $bound = $size_area_map;

    my $offset_lower_y = 0;
    my $offset_lower_x = 0;
    my $offset_top_y = 0;
    my $offset_top_x = 0;

    if ($offset->[$Y] >= 0) {
        $offset_lower_y = $offset->[$Y];
    } else {
        $offset_top_y = -$offset->[$Y];
    }

    if ($offset->[$X] >= 0) {
        $offset_lower_x = $offset->[$X];
    } else {
        $offset_top_x = -$offset->[$X];
    }

    for (my $y = 0; $y + $offset_lower_y < $bound->[$Y]; $y++) {
        for (my $x = 0; $x + $offset_lower_x < $bound->[$X]; $x++) {
            my $symbol = $top_layer->[$y+$offset_top_y][$x+$offset_top_x];
            $lower_layer->[$y+$offset_lower_y][$x+$offset_lower_x] = $symbol;
        }
    }

    return $lower_layer;
}

1;
