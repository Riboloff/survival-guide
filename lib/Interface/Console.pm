package Interface::Console;

use strict;
use warnings;
use utf8;

use Animation;
use Interface::Utils;
use Interface::Window;
use Logger qw(dmp);
use Logger;
use Text;
use Consts;


sub process_text {
    my $interface = shift;

    my $text = Text->new(
        text => $interface->get_console_obj->get_text_flat,
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

    my $console = $interface->get_console_obj;
    my $last_command = $console->get_last_command();
    if ($last_command->{command}) {
        my $ps1 = $interface->get_console_obj->get_ps1;
        $ps1 =~ s/\[.*?\]//g;
        my $offset_x = length($ps1) + 1;
        my $command = $last_command->{command};

        my $offset_y = -1;
        my @out_console = @{$interface->get_console_obj->get_text};
        for (@out_console) {
            $offset_y += scalar split(/\n/, $_->{command});
            $offset_y += scalar split(/\n/, $_->{output});
        }
        my $offset = [
            $offset_y,
            $offset_x,
        ];
        my $coord = $console->get_coord_cur();
        
        my $text_obj = Text->new(
            text => $command,
            area => [[0,0],[1, length $command]],
            frame => 1
        );
        
        #$window->animation_print_text($command, $offset);
        $window->animation_print_text($text_obj->get_text_array(), $coord);
        #my $bound_for_spin = [$hot_text->{number} + 1, 0];
        #$window->animation_print_spin($bound_for_spin, 5);
    }
    $interface->get_console_obj->add_command_from_bufer();

    $window->add_sub_block('text', process_text($interface));
    $interface->{main_block_show} = 'console';

    $interface->create_window($window);

    my $text = $interface->get_console_obj->get_text_flat();
    my @text = split(/\n/, $text);

    my $ps1 = $interface->get_console_obj->get_ps1;
    $ps1 =~ s/\[.*?\]//g;
    my $offset_x = length($ps1) + 1;

    my $coord = [
        $window->{size}{main}[$LT][$Y] + scalar @text,
        $window->{size}{main}[$LT][$X] + $offset_x
    ];

    Animation->get()->add(
        {
            type => 'blink',
            symbols => ['_', ' '],
            mtime => 500,
            block => 'console',
            coord => $coord,
        }
    );

    return;
}

1;
