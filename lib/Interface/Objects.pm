package Interface::Objects;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);
use Interface::Utils;

sub process_list_obj {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $map = $interface->{map}{obj};
    my $character = $interface->{character};
    my $containers = $map->get_container_nigh($character);

    my $area = $interface->{objects}{list_obj}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $list_obj_array = Interface::Utils::init_array($area);

    my $list_obj = [@$containers];
    my $chooser = $interface->{chooser};
    $chooser->{list}{list_obj} = $list_obj;
    my @list = map {$_->get_name()} @$list_obj;

    my $chooser_position = $chooser->get_position('list_obj');
    my $color_chooser = 'on_green';
    if ($chooser->{block_name} eq 'list_obj') {
        $color_chooser = 'on_red';
    }

    my $args = {
        list => \@list,
        array => $list_obj_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => $color_chooser,
    };
    $list_obj_array = Interface::Utils::list_to_array_symbols($args);

    return $list_obj_array;
}

sub process_actions {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $chooser = $interface->{chooser}; 
    my $list_obj = $chooser->{list}{list_obj};
    my $position_list_obj = $chooser->{position}{list_obj};
    my $obj = $list_obj->[$position_list_obj];
    my $list_actions = $obj ? $obj->get_actions() : [];

    $chooser->{list}{action} = $list_actions;

    my $area = $interface->{objects}{action}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $action_array = Interface::Utils::init_array($area);

    my $chooser_position = 0;
    my $color_chooser = 'on_green';
    if ($chooser->{block_name} eq 'action') {
        $chooser_position = $chooser->get_position();
        $color_chooser = 'on_red';
    }

    my $args = {
        list => $list_actions,
        array => $action_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
        color_chooser => $color_chooser,
    };

    $action_array = Interface::Utils::list_to_array_symbols($args);

    return $action_array;
}

sub process_block {
    my $interface = shift;

    my $objects_array = init_objects($interface->{objects});
    my $main_array = $interface->{data_print};

    my $list_obj_array = process_list_obj($interface); 
    my $actions_array = process_actions($interface); 

    my $offset_list_obj = [
        $interface->{objects}{list_obj}{size}[$LT][$Y] - $interface->{objects}{size}[$LT][$Y],
        $interface->{objects}{list_obj}{size}[$LT][$X] - $interface->{objects}{size}[$LT][$X]
    ];
    my $offset_actions = [
        $interface->{objects}{action}{size}[$LT][$Y] - $interface->{objects}{size}[$LT][$Y],
        $interface->{objects}{action}{size}[$LT][$X] - $interface->{objects}{size}[$LT][$X]
    ];
    my $offset_objects = [
        $interface->{objects}{size}[$LT][$Y],
        $interface->{objects}{size}[$LT][$X]
    ];
    Interface::Utils::overlay_arrays_simple($objects_array, $list_obj_array, $offset_list_obj);
    Interface::Utils::overlay_arrays_simple($objects_array, $actions_array, $offset_actions);

    Interface::Utils::overlay_arrays_simple($main_array, $objects_array, $offset_objects);
}

sub init_objects {
    my $objects = shift;

    my $objects_array = [];

    my $size_objects = Interface::Utils::get_size($objects->{size});
    my $size_objects_y = $size_objects->[$Y];
    my $size_objects_x = $size_objects->[$X];

    my $size_list_obj = Interface::Utils::get_size($objects->{list_obj}{size});
    my $size_list_obj_y = $size_list_obj->[$Y];
    my $size_list_obj_x = $size_list_obj->[$X];

    for my $y (0 .. $size_objects_y - 1) {
        for my $x (0 .. $size_objects_x - 1) {
            $objects_array->[$y][$x]{symbol} = ' ';
            $objects_array->[$y][$x]{color} = '';
            if ($x == $size_list_obj_x) {
                $objects_array->[$y][$x]{symbol} = 'ǁ';
                $objects_array->[$y][$x]{color} = '';
            }
        }
    }

    return $objects_array;
}

1;
