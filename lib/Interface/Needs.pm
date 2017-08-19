package Interface::Needs;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Language;
use Logger qw(dmp dmp_array);

sub health_line {
    my $interface = shift;

    my $helth_percent = $interface->{character}->get_health->get_hp();
    my $area = [
        [
            $interface->{needs}{size}[$LT][$Y],
            $interface->{needs}{size}[$LT][$X]
        ],
        [
            $interface->{needs}{size}[$LT][$Y] + 1,
            $interface->{needs}{size}[$RD][$X]
        ]
    ];
    my $size_area = Interface::Utils::get_size($area);

    my $health_line_array = Interface::Utils::init_array($size_area);
    my $text = Language::get_needs('health');
    my $line = [" $text $helth_percent%"];

    my $color_line = 'on_red';
    my $color_text = 'white';

    my $args = {
        line => $line,
        array => $health_line_array,
        size_area => $size_area,
        color_line => $color_line,
        color_text => $color_text,
        color_percent => $helth_percent,
    };
    $health_line_array = Interface::Utils::one_line_to_array_symbols($args);

    return $health_line_array;
}

sub hunger_line {
    my $interface = shift;

    my $hunger_percent = $interface->{character}->get_hunger->get_food();
    my $area = [
        [
            $interface->{needs}{size}[$LT][$Y],
            $interface->{needs}{size}[$LT][$X]
        ],
        [
            $interface->{needs}{size}[$LT][$Y] + 1,
            $interface->{needs}{size}[$RD][$X]
        ]
    ];
    my $size_area = Interface::Utils::get_size($area);

    my $hunger_line_array = Interface::Utils::init_array($size_area);
    my $text = Language::get_needs('hunger');
    my $line = [" $text $hunger_percent%"];

    my $color_line = 'on_red';
    my $color_text = 'white';

    my $args = {
        line => $line,
        array => $hunger_line_array,
        size_area => $size_area,
        color_line => $color_line,
        color_text => $color_text,
        color_percent => $hunger_percent,
    };
    $hunger_line_array = Interface::Utils::one_line_to_array_symbols($args);

    return $hunger_line_array;
}

sub thirst_line {
    my $interface = shift;

    my $thirst_percent = $interface->{character}->get_thirst->get_water();
    my $area = [
        [
            $interface->{needs}{size}[$LT][$Y],
            $interface->{needs}{size}[$LT][$X]
        ],
        [
            $interface->{needs}{size}[$LT][$Y] + 1,
            $interface->{needs}{size}[$RD][$X]
        ]
    ];
    my $size_area = Interface::Utils::get_size($area);

    my $thirst_line_array = Interface::Utils::init_array($size_area);
    my $text = Language::get_needs('thirst');
    my $line = [" $text $thirst_percent%"];

    my $color_line = 'on_red';
    my $color_text = 'white';

    my $args = {
        line => $line,
        array => $thirst_line_array,
        size_area => $size_area,
        color_line => $color_line,
        color_text => $color_text,
        color_percent => $thirst_percent,
    };
    $thirst_line_array = Interface::Utils::one_line_to_array_symbols($args);

    return $thirst_line_array;
}

sub temp_line {
    my $interface = shift;

    my $temp = $interface->{character}->get_temp->get_temp_result();
    my $temp_percent = int ($temp * 100 / 36.6);
    #my $temp_percent = 50;#$interface->{character}->get_thirst->get_water();
    my $area = [
        [
            $interface->{needs}{size}[$LT][$Y],
            $interface->{needs}{size}[$LT][$X]
        ],
        [
            $interface->{needs}{size}[$LT][$Y] + 1,
            $interface->{needs}{size}[$RD][$X]
        ]
    ];
    my $size_area = Interface::Utils::get_size($area);

    my $temp_line_array = Interface::Utils::init_array($size_area);
    my $key_text = 'temp_norm';
    if ($temp_percent < 40) {
        $key_text = 'temp_cold';
    }
    elsif ($temp_percent > 80) {
        $key_text = 'temp_hot';
    }
    my $text = Language::get_needs($key_text);
    my $line = [" $text $temp_percent%"];

    #TODO строку для тепла делать подругому, 
    my $color_line = 'on_red';
    my $color_text = 'white';

    my $args = {
        line => $line,
        array => $temp_line_array,
        size_area => $size_area,
        color_line => $color_line,
        color_text => $color_text,
        color_percent => $temp_percent,
    };
    $temp_line_array = Interface::Utils::one_line_to_array_symbols($args);

    return $temp_line_array;
}

sub process_block {
    my $interface = shift;

    my $needs_array = init_needs($interface->{needs});
    my $main_array = $interface->{data_print};

    my $health_line_array = health_line($interface); 
    my $hunger_line_array = hunger_line($interface); 
    my $thirst_line_array = thirst_line($interface); 
    my $temp_line_array   =   temp_line($interface); 

    my $offset_health_line = [0, 0];
    my $offset_hunger_line = [2, 0];
    my $offset_thirst_line = [4, 0];
    my   $offset_temp_line = [6, 0];

    my $offset_needs = [
        $interface->{needs}{size}[$LT][$Y],
        $interface->{needs}{size}[$LT][$X]
    ];
    Interface::Utils::overlay_arrays_simple($needs_array, $health_line_array, $offset_health_line);
    Interface::Utils::overlay_arrays_simple($needs_array, $hunger_line_array, $offset_hunger_line);
    Interface::Utils::overlay_arrays_simple($needs_array, $thirst_line_array, $offset_thirst_line);
    Interface::Utils::overlay_arrays_simple($needs_array,   $temp_line_array,   $offset_temp_line);
    my $needs_frame_array = Interface::Utils::get_frame($needs_array);

    Interface::Utils::overlay_arrays_simple($main_array, $needs_frame_array, $offset_needs);
}

sub init_needs {
    my $needs = shift;

    my $needs_array = [];

    my $size_needs = Interface::Utils::get_size($needs->{size});
    my $size_needs_y = $size_needs->[$Y];
    my $size_needs_x = $size_needs->[$X];


    for my $y (0 .. $size_needs_y - 1) {
        for my $x (0 .. $size_needs_x - 1) {
            $needs_array->[$y][$x]{symbol} = ' ';
            $needs_array->[$y][$x]{color} = '';
        }
    }

    return $needs_array;
}

1;
