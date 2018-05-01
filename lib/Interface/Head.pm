package Interface::Head;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Language;
use Logger qw(dmp);

sub process_block {
    my $interface = shift;

    my $head = $interface->get_head;
    my $head_array = init_head($head); 

    my $size_cell_x = 9;

    my $block_show = $interface->get_main_block_show_name();
    my $blocks = ['map', 'craft', 'inv', 'char', 'console'];

    my @one_str = ();
    my @two_str = ();
    for my $block_name (@$blocks) {
        my $start_symbol_title = 0;
        my @title_array = split(//, Language::get_head($block_name));
        if (@title_array <= $size_cell_x) {
            $start_symbol_title = int($size_cell_x / 2 - @title_array / 2);
        }
        my @cell_array = ();
        for (my $x = 0; $x < $size_cell_x; $x++) {
            $cell_array[0][$x]->{symbol} = '';
            $cell_array[0][$x]->{color} = '';
            if ($x == 0 or $x == $size_cell_x - 1) {
                $cell_array[0][$x]->{symbol} = '│';
            }
            if (
                $start_symbol_title <= $x
                and ($x - $start_symbol_title) < @title_array
            ) {
                $cell_array[0][$x]->{symbol} = $title_array[$x - $start_symbol_title];
                $cell_array[0][$x]->{color} = 'white';
                if ($block_name eq $block_show) {
                    $cell_array[0][$x]->{color} = 'green';
                }
            }

            $cell_array[1][$x]->{symbol} = '─';
            $cell_array[1][$x]->{color} = '';

            if ($block_name eq $block_show) {
                $cell_array[1][$x]->{symbol} = ' ';
            }
            if ($cell_array[0][$x]->{symbol} eq '│') {
                if ($block_name eq $block_show) {
                    if ($x < $start_symbol_title) {
                        $cell_array[1][$x]->{symbol} = '┘';
                    }
                    else {
                        $cell_array[1][$x]->{symbol} = '└';
                    }
                }
                else {
                    $cell_array[1][$x]->{symbol} = '┴';
                }
            }

        }
        push @one_str, @{$cell_array[0]};
        push @two_str, @{$cell_array[1]};
    }

    my $main_array = $interface->{data_print};

    my $offset = [
        $interface->get_head->{size}[$LT][$Y],
        $interface->get_head->{size}[$LT][$X]
    ];
    my $tmp = [];
    push @$tmp, \@one_str, \@two_str;

    Interface::Utils::overlay_arrays_simple($head_array, $tmp, [0,0]);
    Interface::Utils::overlay_arrays_simple($main_array, $head_array, $offset);
}

sub init_head {
    my $head = shift;

    my $head_array = [];
    my $y_bound_head = $head->{size}->[$RD][$Y];
    my $x_bound_head = $head->{size}->[$RD][$X];

    for my $y (0 .. $y_bound_head) {
        for my $x (0 .. $x_bound_head - 1) {
            $head_array->[$y][$x]->{symbol} = ' ';
            $head_array->[$y][$x]->{color} = '';
            if ($y == 1) {
                $head_array->[$y][$x]->{symbol} = '─';
            }
        }
    }

    return $head_array;
}

1;
