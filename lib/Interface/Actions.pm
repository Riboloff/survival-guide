package Interface::Actions;

use strict;
use warnings;

use Consts;
use Interface::Utils;

sub process_block {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $chooser = $interface->{chooser}; 
    my $list_obj = $chooser->{list}{list_obj};
    my $position_list_obj = $chooser->{position}{list_obj};
    my $obj = $list_obj->[$position_list_obj];
    my $list_actions = $obj ? $obj->get_actions() : [];

    $chooser->{list}{action} = $list_actions;

    my $area = $interface->{action}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $action_array = Interface::Utils::init_array($area);

    my $chooser_position = 0;
    if ($chooser->{block_name} eq 'action') {
        $chooser_position = $chooser->get_position();
    }

    my $args = {
        list => $list_actions,
        array => $action_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
    };

    $action_array = Interface::Utils::list_to_array_symbols($args);

    my $offset = [
        $interface->{action}{size}[$LT][$Y],
        $interface->{action}{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($main_array, $action_array, $offset);
}

1;
