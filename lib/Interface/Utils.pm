package Interface::Utils;

use strict;
use warnings;
use utf8;

use Consts;
use List::Util qw(min);
use Logger qw(dmp);

sub is_object_into_area {
    my $size_area = shift;
    my $object_array = shift;

    my $y_obj = scalar @$object_array;
    my $x_obj = scalar @{$object_array->[0]};
    my ($y_ar, $x_ar) = @$size_area;
    if ($y_ar >= $y_obj and $x_ar >= $x_obj) {
        return 1;
    }

    return 0;
}

#Второй массив поверх первого с учетом смещения
sub overlay_arrays_simple {
    my $lower_layer = shift;
    my $top_layer = shift;
    my $offset = shift || [0, 0];

    my $offset_y = $offset->[$Y];
    my $offset_x = $offset->[$X];
    if ($offset_y < 0 or $offset_x < 0) {
        die('$offset_y < 0 or $offset_x < 0');
    }
    for (my $y = 0; $y < @$top_layer; $y++) {
        for (my $x = 0; $x < @{$top_layer->[0]}; $x++) {
            my $symbol = $top_layer->[$y][$x];
            $lower_layer->[$y+$offset_y][$x+$offset_x] = $symbol;
        }
    }
}

sub get_center {
    my $array = shift;

    my $size = [];
    if (ref $array->[0] eq 'ARRAY') {
        $size->[$Y] = @$array;
        $size->[$X] = @{$array->[0]};
    } else { #Передан не двухмерный массив, а размер массива
        $size = $array;
    }

    return [
        int( $size->[$Y] / 2 ),
        int( $size->[$X] / 2 )
    ];
}

sub get_offset {
    my $array_1 = shift;
    my $array_2 = shift;

    my $center_1 = get_center($array_1);
    my $center_2 = get_center($array_2);

    return [
        $center_1->[$Y] - $center_2->[$Y],
        $center_1->[$X] - $center_2->[$X]
    ]
}

sub clear_area {
    my $main_array = shift;
    my $size_area_map = shift;
    my $offset = shift || [0, 0];

    my $offset_y = $offset->[$Y];
    my $offset_x = $offset->[$X];
    for (my $y = 0; $y < $size_area_map->[$Y]; $y++) {
        for (my $x = 0; $x < $size_area_map->[$X]; $x++) {
            $main_array->[$y + $offset_y][$x + $offset_x]->{symbol} = ' ';
            $main_array->[$y + $offset_y][$x + $offset_x]->{color} = '';
        }
    }
}

sub get_size {
    my $coords = shift;

    my $size = [
        $coords->[$RD][$Y] - $coords->[$LT][$Y],
        $coords->[$RD][$X] - $coords->[$LT][$X]
    ];

    return $size;
}

sub get_size_without_frame {
    my $coords = shift;

    my $size = [
        $coords->[$RD][$Y] - $coords->[$LT][$Y] - 2,
        $coords->[$RD][$X] - $coords->[$LT][$X] - 2
    ];

    return $size;
}

sub init_array {
    my $size_area = shift;

    my $action_array = [];
    for (my $y = 0; $y < $size_area->[$Y]; $y++) {
        for (my $x = 0; $x < $size_area->[$X]; $x++) {
            my $symbol = ' ';
            my $color = '';
            $action_array->[$y][$x] = {
               'color' => $color,
               'symbol' => $symbol,
            }
        }
    }

    return $action_array;
}

sub init_array_area {
    my $obj   = shift;
    my $title = shift;

    my $area = $obj->{size};
    my $size_area = $obj->{size_area} = Interface::Utils::get_size($area);
    $obj->{size_area_frame} = [
        $obj->{size_area}[$Y] - 2,
        $obj->{size_area}[$X] - 2,
    ];

    my $array = [];
    for (my $y = 0; $y < $size_area->[$Y]; $y++) {
        for (my $x = 0; $x < $size_area->[$X]; $x++) {
            my $symbol = ' ';
            my $color = '';
            $array->[$y][$x] = {
               'color' => $color,
               'symbol' => $symbol,
            }
        }
    }

    $array = get_frame($array, $title);
    $obj->{array_area} = $array;

    return $array;
}

sub list_to_array_symbols {
    my $args = shift;

    my $list = $args->{list};
    my $array = $args->{array};
    my $chooser_position = $args->{chooser_position} || 0;
    my $size_area = $args->{size_area};
    my $color_chooser =  $args->{color_chooser} || 'on_green';


    for (my $y=0; $y < @$list; $y++) {
        my @symbols = split( //, $list->[$y]);
        my $color = '';
        if ($chooser_position == $y) {
            $color = $color_chooser;
            for (my $x = 0; $x < $size_area->[$X]; $x++) {
                $array->[$y][$x]{'color'} = $color;
            }
        }

        my $bound = min(scalar @symbols, $size_area->[$X]);
        for (my $x=0; $x < $bound; $x++) {
            $array->[$y][$x]{symbol} = $symbols[$x];
        }
    }

    return $array;
}

sub list_to_array_symbols_frame {
    my $args = shift;

    my $list = $args->{list};
    my $array = $args->{array};
    my $chooser_position = $args->{chooser_position} || 0;
    my $size_area = $args->{size_area_frame};
    my $color_chooser =  $args->{color_chooser} || 'on_green';

    for (my $y=0; $y < @$list; $y++) {
        my @symbols = split( //, $list->[$y]);
        my $color = '';
        if ($chooser_position == $y) {
            $color = $color_chooser;
            for (my $x = 0; $x < $size_area->[$X]; $x++) {
                $array->[$y+1][$x+1]{'color'} = $color;
            }
        }

        my $bound = min(scalar @symbols, $size_area->[$X]);
        for (my $x=0; $x < $bound; $x++) {
            $array->[$y+1][$x+1]{symbol} = $symbols[$x];
        }
    }

    return $array;
}

sub one_line_to_array_symbols {
    my $args = shift;

    my $line = $args->{line};
    my $array = $args->{array};
    my $size_area = $args->{size_area};
    my $color_line =  $args->{color_line} // 'red';
    my $color_text =  $args->{color_text} // '';
    my $color_percent = $args->{color_percent} // 100;

    my $length_text = $size_area->[$X];
    my $length_line = int ($size_area->[$X] * $color_percent/100);
    my @symbols = split(//, $line->[0]);
    for (my $x = 0; $x < $size_area->[$X]; $x++) {
        if ($x >= $length_line) {
            $color_line = 'on_blue';
        }
        $array->[0][$x]{'color'} = "$color_text,$color_line";

    }

    my $bound = min(scalar @symbols, $size_area->[$X]);
    for (my $x=0; $x < $bound; $x++) {
        $array->[0][$x]{symbol} = $symbols[$x];
    }

    return $array;
}

sub get_frame {
    my $array = shift;
    my $title = shift || '';

    my $array_frame = [];
    my $size_array_frame_y = scalar( @$array );
    my $size_array_frame_x = scalar( @{$array->[0]} );

    my $color = 'dark';

    my $start_symbol_title = 0;
    my @title_array = ();
    if ($title) {
        @title_array = split(//, $title);
        if (@title_array <= $size_array_frame_x + 2) {
            $start_symbol_title = int($size_array_frame_x / 2 - @title_array / 2);
        }
    }
    for (my $y = 0; $y < $size_array_frame_y; $y++) {
        for (my $x = 0; $x < $size_array_frame_x; $x++) {
            if ($x == 0 and $y == 0) {
                $array_frame->[$y][$x]->{symbol} = '╭';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == 0 and $y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '╰';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == $size_array_frame_x - 1 and $y == 0) {
                $array_frame->[$y][$x]->{symbol} = '╮';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == $size_array_frame_x - 1 and $y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '╯';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($y == 0) {
                if (
                    $title
                    and $start_symbol_title <= $x
                    and ($x - $start_symbol_title) < @title_array
                ) {
                    my $symbol = $title_array[$x - $start_symbol_title];
                    $array_frame->[$y][$x]->{symbol} = $symbol;
                    $array_frame->[$y][$x]->{color} = 'dark green';
                } else {
                    $array_frame->[$y][$x]->{symbol} = '─';
                    $array_frame->[$y][$x]->{color} = $color;
                }
            }
            elsif ($y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '─';
                $array_frame->[$y][$x]->{color} = $color;
            }
            elsif ($x == 0 or $x == $size_array_frame_x - 1) {
                $array_frame->[$y][$x]->{symbol} = '│';
                $array_frame->[$y][$x]{color} = $color;
            }
            else {
                $array_frame->[$y][$x]{symbol} = $array->[$y][$x]{symbol};
                $array_frame->[$y][$x]{color} = $array->[$y][$x]{color};
            }

        }
    }
    #Чтобы влезла рамка, сдвигаем массив с данными на два символа.
    pop(@$array);
    pop(@$array);
    pop(@{$array->[0]});
    pop(@{$array->[0]});

    overlay_arrays_simple($array_frame, $array, [1, 1] );
    return $array_frame;
}

#get_frame и get_frame_tmp
#Первый делает рамку из входного массива
#Второй оборачивает входной массив в рамку
#TODO сделать нормальные названия
sub get_frame_tmp {
    my $array = shift;

    my $color = 'dark';

    my $array_frame = [];
    my $size_array_frame_y = scalar( @$array ) + 2;
    my $size_array_frame_x = scalar( @{$array->[0]} + 2 );

    for (my $y = 0; $y < $size_array_frame_y; $y++) {
        for (my $x = 0; $x < $size_array_frame_x; $x++) {
            if ($x == 0 and $y == 0) {
                $array_frame->[$y][$x]->{symbol} = '╭';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == 0 and $y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '╰';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == $size_array_frame_x - 1 and $y == 0) {
                $array_frame->[$y][$x]->{symbol} = '╮';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($x == $size_array_frame_x - 1 and $y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '╯';
                $array_frame->[$y][$x]{color} = $color;
            }
            elsif ($y == 0 or $y == $size_array_frame_y - 1) {
                $array_frame->[$y][$x]->{symbol} = '─';
                $array_frame->[$y][$x]->{color} = $color;
            }
            elsif ($x == 0 or $x == $size_array_frame_x - 1) {
                $array_frame->[$y][$x]->{symbol} = '│';
                $array_frame->[$y][$x]{color} = $color;
            }
        }
    }

    overlay_arrays_simple($array_frame, $array, [1, 1] );
    return $array_frame;
}

sub get_size_data {
    my $offset = shift;
    my $array_data = shift;

    my $size_data;
    $size_data->[$LT] =  $offset;
    $size_data->[$RD] = [
        $offset->[$Y] + scalar @{$array_data},
        $offset->[$X] + scalar @{$array_data->[0]},
    ];

    return $size_data;
}

1;
