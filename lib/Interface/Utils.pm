package Interface::Utils;

use strict;
use warnings;

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
            $main_array->[$y + $offset_y][$x + $offset_x] = ' ';
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

sub init_array {
    my $area = shift;
    my $size_area = shift;
    my $frame = shift // 0;

    if (!$size_area) {
        $size_area = get_size($area);
    }

    my $action_array = [];
    for (my $y=0; $y < $size_area->[$Y]; $y++) {
        for (my $x=0; $x < $size_area->[$X]; $x++) {
            my $symbol = ' ';
            my $color = '';
            if ($frame and ($x==0 or $x==$size_area->[$X]-1)) {
                $symbol = '|';
                $color = 'red';
            }
            if ($frame and ($y==0 or $y==$size_area->[$Y]-1)) {
                $symbol = '-';
                $color = 'red';
            }
            $action_array->[$y][$x] = {
               'color' => $color,
               'symbol' => $symbol,
            }
        }
    }

    return $action_array;
}

sub list_to_array_symbols {
    my $args = shift;

    my $list = $args->{list};
    my $array = $args->{array};
    my $chooser_position = $args->{chooser_position} || 0;
    my $size_area = $args->{size_area};


    for (my $y=0; $y < @$list; $y++) {
        my @symbols = split( //, $list->[$y]);
        my $color = '';
        if ($chooser_position == $y) {
            $color = 'on_green';
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

1;
