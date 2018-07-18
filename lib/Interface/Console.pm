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

    my $text_frame_array = Interface::Utils::get_frame_tmp($text_array, {title => $title});
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

    my $hot_text = $interface->get_console_obj->get_hot_text();
    if ($hot_text->{string}) {
        my $ps1 = $interface->get_console_obj->get_ps1;
        $ps1 =~ s/\[.*?\]//g;
        my $offset_x = length($ps1) + 1;
        $window->animation_print_text($hot_text, $offset_x);
        my $bound_for_spin = [$hot_text->{number} + 1, 0];
        $window->animation_print_spin($bound_for_spin, 5);
    }

    $interface->{main_block_show} = 'console';

    $interface->create_window($window);

    return;
}

1;
