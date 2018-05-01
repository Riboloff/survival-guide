package Interface::Console;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Interface::Window;
use Logger qw(dmp);
use Storable qw(dclone);
use Text;

sub process_text {
    my $interface = shift;

    my $text = Text->new(undef, '1234567890');
    my $area = $interface->get_console_text->{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('console');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);
    return $text_frame_array;
}

sub process_block {
    my $interface = shift;

    my $console = $interface->{console};

    my $text = process_text($interface);
    my $window = Interface::Window->new(
            size => {
                main => $interface->get_console->{size},
                sub => {
                    text => $interface->get_console_text->{size}, 
                }
            }
    );

    $window->add_sub_block('text',   $text);

    if ($interface->{main_block_show} ne 'console') {
        $window->animation_appearance_top();
    }
    $interface->{main_block_show} = 'console';

    $interface->create_window($window->{array});

    return;
}

1;
