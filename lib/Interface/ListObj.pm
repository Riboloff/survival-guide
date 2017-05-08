package Interface::ListObj;

use strict;
use warnings;

use Consts;
use Interface::Utils;

sub process_block {
    my $interface = shift;

    my $main_array = $interface->{data_print};
    my $map = $interface->{map}{obj};
    my $moving_obj_main_coord = $interface->{moving_obj}{A};
    my $containers = $map->get_container_nigh($moving_obj_main_coord);
    
    my $area = $interface->{list_obj}{size};
    my $size_area = Interface::Utils::get_size($area);

    my $obj_array = Interface::Utils::init_array($area);

    my $list_obj = [@$containers];
    my $chooser = $interface->{chooser};
    $chooser->{list}{list_obj} = $list_obj;
   
    my @list = map {$_->get_name()} @$list_obj;
    my $chooser_position = $chooser->get_position();

    my $args = {
        list => \@list,
        array => $obj_array,
        chooser_position => $chooser_position,
        size_area => $size_area,
    };
    Interface::Utils::list_to_array_symbols($args);

    my $offset = [
        $interface->{list_obj}{size}[$LT][$Y],
        $interface->{list_obj}{size}[$LT][$X]
    ];
    Interface::Utils::overlay_arrays_simple($main_array, $obj_array, $offset);

    Interface::Actions::process_block($interface);
    if (ref $interface->{old_data_print}->[0] eq 'ARRAY') {
        $interface->_get_screen_diff('action');
    }
}
1;
