package Interface::Health;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Logger qw(dmp dmp_array);

sub health_line {
    my $interface = shift;

    my $helth_percent = 10;
    my $area = [
        [
            $interface->{health}{size}[$LT][$Y],
            $interface->{health}{size}[$LT][$X]
        ],
        [
            $interface->{health}{size}[$LT][$Y] + 1,
            $interface->{health}{size}[$RD][$X]
        ]
    ];
    my $size_area = Interface::Utils::get_size($area);

    my $health_line_array = Interface::Utils::init_array($area, $size_area);
    my $line = ["Здоровье $helth_percent%"];

    my $color_line = 'on_white';
    my $color_text = 'red';

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

sub process_block {
    my $interface = shift;

    my $health_array = init_health($interface->{health});
    my $main_array = $interface->{data_print};

    my $health_line_array = health_line($interface); 

    my $offset_health_line = [0, 0];
    my $offset_health = [
        $interface->{health}{size}[$LT][$Y],
        $interface->{health}{size}[$LT][$X]
    ];
    Interface::Utils::overlay_arrays_simple($health_array, $health_line_array, $offset_health_line);
    Interface::Utils::overlay_arrays_simple($main_array, $health_array, $offset_health);
}

sub init_health {
    my $health = shift;

    my $health_array = [];

    my $size_health = Interface::Utils::get_size($health->{size});
    my $size_health_y = $size_health->[$Y];
    my $size_health_x = $size_health->[$X];


    for my $y (0 .. $size_health_y - 1) {
        for my $x (0 .. $size_health_x - 1) {
            $health_array->[$y][$x]{symbol} = ' ';
            $health_array->[$y][$x]{color} = '';
        }
    }

    return $health_array;
}

1;
