package Interface::Look;

use strict;
use warnings;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);
use Text;

sub process_block {
    my $interface = shift;

    my $window = Interface::Window->new(
            size => {
                name => 'look',
                main => $interface->get_look->{size},
                sub => {
                    text => $interface->get_look->{size},
                }
            }
    );

    my $position = $interface->get_target->get_position();

    my @desc = ();
    if ($position) {
        my $map_array = $interface->get_map_obj->{map_array_obj};
        my $cell = $map_array->[$position->[$Y]][$position->[$X]];
        if (ref $cell eq 'Cell') {
            my $objs = $cell->get_all_objs;
            for my $obj (@$objs) {
                next if (ref $obj eq 'Target');

                if (UNIVERSAL::can($obj, 'get_look')) {
                    push(@desc, $obj->get_look());
                }
                else {
                    push(@desc, $obj->get_desc());
                }
            }
        }

        #for my $str_num (1 .. @desc) {
        #    $desc[$str_num-1] = $str_num  .  '. '  . $desc[$str_num-1];
        #}
    }
    my $text = Text->new(
        text => join("\n----------\n", @desc),
        area => $interface->get_look->{size},
    );
    my $text_array = $text->get_text_array();
    my $area = Interface::Utils::get_size_without_frame($text->{area});
    my $text_frame_array = Interface::Utils::get_frame_tmp(
        $text_array,
        {
            scroll => $text->{scroll},
            count_string => scalar @{$text->{array}},
            area_y => $area->[$Y],
        }
    );

    $window->add_sub_block('text', $text_frame_array);

    $interface->create_window($window);
}

1;
