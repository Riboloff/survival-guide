package Interface::Text;

use strict;
use warnings;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);

sub process_block {
    my $interface = shift;

    my $text = $interface->{text}{obj};
    my $size_area_text = Interface::Utils::get_size_without_frame($interface->{text}{size});
    #my $size_area_text = Interface::Utils::get_size($interface->{text}{size});
    my $text_array = $text->get_text_array($size_area_text);
    my $size_area_text_lt = $interface->{text}{size}[$LT];
    my $main_array = $interface->{data_print};

    my $scroll = $text->{scroll};

    my $offset = [
        $size_area_text_lt->[$Y],
        $size_area_text_lt->[$X],
    ];


    if (Interface::Utils::is_object_into_area($size_area_text, $text_array) ) {
        my $text_frame_array = Interface::Utils::get_frame_tmp($text_array);

        Interface::Utils::overlay_arrays_simple($main_array, $text_frame_array, $offset);
    } else {
        my $last_str_number = @$text_array - $scroll - 1;
        my $first_str_number = $last_str_number - ($size_area_text->[$Y] - 1); 
        my $text_array_chank = [@$text_array[$first_str_number .. $last_str_number]];

        my $text_frame_array_chank = Interface::Utils::get_frame_tmp($text_array_chank);
        Interface::Utils::overlay_arrays_simple($main_array, $text_frame_array_chank, $offset);
    }
}

1;
