package Interface::Text;

use strict;
use warnings;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);

sub process_block {
    my $interface = shift;

    my $window = Interface::Window->new(
            size => {
                name => 'text',
                main => $interface->get_text->{size},
                sub => {
                    text => $interface->get_text->{size},
                }
            }
    );

    my $text = $interface->get_text_obj();
    my $text_array = $text->get_text_array();
    my $text_frame_array = Interface::Utils::get_frame_tmp($text_array);

    $window->add_sub_block('text', $text_frame_array);

    $interface->create_window($window);
}

1;
