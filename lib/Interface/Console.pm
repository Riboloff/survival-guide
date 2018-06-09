package Interface::Console;

use strict;
use warnings;
use utf8;

use Interface::Utils;
use Interface::Window;
use Logger qw(dmp);
use Logger;
use Text;

sub process_text {
    my $interface = shift;

    my $text = Text->new(
        text => $interface->get_console_obj->get_text,
        area => $interface->get_console_text->{size},
    );

    my $area = $interface->get_console_text->{size};
    my $text_array = $text->get_text_array();
    my $title = Language::get_title_block('console');

    my $text_frame_array = Interface::Utils::get_frame_tmp($text_array, $title);
    return $text_frame_array;
}

sub process_block {
    my $interface = shift;

    my %init_window = (
        size => {
            main => $interface->get_console->{size},
            sub => {
                text => $interface->get_console_text->{size},
            }
        }
    );

    my $window = Interface::Window->new(%init_window);

    $window->add_sub_block('text', process_text($interface));

    if ($interface->{main_block_show} ne 'console') {
        $window->animation_appearance_top();
    }
    $interface->{main_block_show} = 'console';

    $interface->create_window($window);

    return;
}

1;
