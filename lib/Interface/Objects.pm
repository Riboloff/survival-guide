package Interface::Objects;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);
use Storable qw(dclone);

sub process_list_obj {
    my $interface = shift;

    my $map = $interface->{map}{obj};
    my $character = $interface->{character};

    my $list_obj_array = dclone($interface->get_list_obj->{array_area});

    my $list_obj = [
        @{$map->get_objects_nigh($character)},
        @{$interface->get_bots_nearby($character->get_coord)},
    ];
    my $chooser = $interface->{chooser};
    $chooser->{list}{list_obj} = $list_obj;
    my @list = map {$_->get_name()} @$list_obj;

    my $chooser_position = $chooser->get_position('list_obj');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$list_obj);
    my $color_chooser = 'on_green';
    #if ($chooser->{block_name} eq 'list_obj') {
    #    $color_chooser = 'on_red';
    #}
    if ($chooser->{block_name} ne 'list_obj') {
        $chooser_position = 999;
    }

    my $args = {
        list => \@list,
        array => $list_obj_array,
        chooser_position => $chooser_position,
        size_area_frame => $interface->get_list_obj->{size_area_frame},
        color_chooser => $color_chooser,
    };

    $list_obj_array = Interface::Utils::list_to_array_symbols_frame($args);
  
    return $list_obj_array;
}

sub process_actions {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $list_obj = $chooser->{list}{list_obj};
    my $position_list_obj = $chooser->{position}{list_obj};
    my $obj = $list_obj->[$position_list_obj];
    my $list_actions = $obj ? $obj->get_actions() : [];

    $chooser->{list}{action} = $list_actions;

    my $action_array = dclone($interface->get_action->{array_area});

    my $chooser_position = $chooser->get_position('action');
    $chooser_position = Utils::clamp($chooser_position, 0, $#$list_actions);
    my $color_chooser = 'on_green';
    #if ($chooser->{block_name} eq 'action') {
    #    $chooser_position = $chooser->get_position();
    #    $color_chooser = 'on_red';
    #}
    if ($chooser->{block_name} ne 'action') {
        $chooser_position = 999;
    }

    my @list = map {$_->get_name()} @$list_actions;
    my $args = {
        list => \@list,
        array => $action_array,
        chooser_position => $chooser_position,
        size_area_frame => $interface->get_action->{size_area_frame},
        color_chooser => $color_chooser,
    };

    $action_array = Interface::Utils::list_to_array_symbols_frame($args);

    return $action_array;
}

sub process_block {
    my $interface = shift;

    my $objects_array = $interface->get_objects->{array_area};
    my $main_array = $interface->{data_print};

    my $list_obj_array = process_list_obj($interface);
    my $actions_array  = process_actions ($interface);

    my $offset_list_obj = [
        $interface->get_list_obj->{size}[$LT][$Y] - $interface->get_objects->{size}[$LT][$Y],
        $interface->get_list_obj->{size}[$LT][$X] - $interface->get_objects->{size}[$LT][$X]
    ];
    my $offset_actions = [
        $interface->get_action->{size}[$LT][$Y] - $interface->get_objects->{size}[$LT][$Y],
        $interface->get_action->{size}[$LT][$X] - $interface->get_objects->{size}[$LT][$X]
    ];
    my $offset_objects = [
        $interface->get_objects->{size}[$LT][$Y],
        $interface->get_objects->{size}[$LT][$X]
    ];

    my $offset_data_actions = [
        $offset_objects->[$Y] + $offset_actions->[$Y],
        $offset_objects->[$X] + $offset_actions->[$X]
    ];
    $interface->get_action->{size_data} = Interface::Utils::get_size_data($offset_data_actions, $actions_array);

    my $offset_data_list_obj = [
        $offset_objects->[$Y] + $offset_list_obj->[$Y],
        $offset_objects->[$X] + $offset_list_obj->[$X]
    ];
    $interface->get_list_obj->{size_data} = Interface::Utils::get_size_data($offset_data_list_obj, $list_obj_array);

    Interface::Utils::overlay_arrays_simple($objects_array, $list_obj_array, $offset_list_obj);
    Interface::Utils::overlay_arrays_simple($objects_array, $actions_array, $offset_actions);

    Interface::Utils::overlay_arrays_simple($main_array, $objects_array, $offset_objects);
}

1;
