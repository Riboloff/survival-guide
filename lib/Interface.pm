package Interface;

use strict;
use warnings;

use Storable qw(dclone);
use Term::ANSIColor;
use Term::ReadKey;
use Term::Cap;
use POSIX;
use List::Util qw(min);

use Data::Dumper;
use utf8;

use lib qw(lib);
use Consts qw($X $Y $LT $RD $size_term);
use Printer;
use Logger qw(dmp dmp_array);
use Interface::Map;
use Interface::Text;
use Interface::ListObj;
use Interface::Actions;
use Interface::Inv;

sub new {
    my $self = shift;
    my $map = shift;
    my $moving_obj = shift;
    my $text_obj = shift;
    my $chooser = shift;
    my $inv = shift;

    system('clear');

    my $size_interface = _get_size_interface();
    my $size_area_map = _get_size_area_map($size_interface);
    my $size_area_text = _get_size_area_text($size_interface, $size_area_map),
    my $size_area_list_obj = _get_size_area_list_obj($size_interface, $size_area_map);
    my $size_area_action = _get_size_area_action($size_interface, $size_area_list_obj);
    my $size_area_inv = _get_size_area_inv($size_interface, $size_area_map);
    my $size_area_bag = _get_size_area_bag($size_interface, $size_area_inv);
    my $size_area_harness = _get_size_area_harness($size_interface, $size_area_inv, $size_area_bag);
    my $data_print = _data_print_init($size_interface, $size_area_map, $size_area_list_obj);

    $text_obj->inition($size_area_text);

    my $hash = {
        map => {
            obj => $map,
            size => $size_area_map,
        },
        moving_obj => $moving_obj,
        size => $size_interface,
        data_print  => $data_print,
        old_data_print => [],
        text => {
            obj => $text_obj,
            size => $size_area_text,
        },
        list_obj => {
            size => $size_area_list_obj,
            chooser_list => [],
        },
        action => {
            size => $size_area_action,
        },
        chooser => $chooser,
        inv => {
            obj => $inv,
            size => $size_area_inv,
            bag => {
                size => $size_area_bag,
            },
            harness => {
                size => $size_area_harness,
            },
        },
    };

    return bless($hash, $self);
}

sub _data_print_init {
    my $size_interface = shift;
    my $size_area_map = shift;
    my $size_area_list_obj = shift;

    my $array = [];
    my $y_bound_map = $size_area_map->[$RD][$Y];
    my $x_bound_map = $size_area_map->[$RD][$X];

    my $y_bound_list_obj = $size_area_list_obj->[$RD][$Y];
    my $x_bound_list_obj = $size_area_list_obj->[$RD][$X];

    for my $y (0 .. $size_interface->[$RD][$Y] - 1) {
        for my $x (0 .. $size_interface->[$RD][$X] - 1) {
            $array->[$y][$x]->{symbol} = '';
            $array->[$y][$x]->{color} = '';
            if ($y == $y_bound_map) {
                $array->[$y][$x]->{symbol} = '=';
                $array->[$y][$x]->{color} = '';
            }
            if ($x == $x_bound_map) {
                $array->[$y][$x]->{symbol} = 'ǁ';
                $array->[$y][$x]->{color} = '';
            }
            if ($y < $y_bound_map and $x == $x_bound_list_obj) {
                $array->[$y][$x]->{symbol} = 'ǁ';
                $array->[$y][$x]->{color} = '';
            }
        }
    }

    return $array;
}

sub print {
    my $self = shift;
    my $process_block = shift;

    if (ref $self->{old_data_print}->[0] ne 'ARRAY') {
        $self->_process_block('all');
        my $array = $self->{data_print};
        $self->{old_data_print} = dclone($array);
        Printer::print_all($array);
    } elsif ($process_block->{all}) {
        $self->_process_block('all');
        my $array = $self->{data_print};
        $self->{old_data_print} = dclone($array);
        #Printer::clean_screen();
        Printer::print_all($array);
    } else {
        for my $block (keys %$process_block) {
            $self->_process_block($block);
            $self->_get_screen_diff($block);
        }
        Printer::print_diff($self->{diff});
        $self->{diff} = {};
    }
}


sub _process_block {
    my $self = shift;
    my $block = shift;

    if ($block eq 'map') {
        Interface::Map::process_block($self);
    } elsif ($block eq 'text') {
        Interface::Text::process_block($self);
    } elsif ($block eq 'list_obj') {
        Interface::ListObj::process_block($self);
    } elsif ($block eq 'action') {
        Interface::Actions::process_block($self);
    } elsif ($block eq 'inv') {
        Interface::Inv::process_block($self);
    } elsif ($block eq 'all') {
        Interface::Map::process_block($self);
        Interface::Text::process_block($self);
        Interface::ListObj::process_block($self);
    }
}

sub _get_screen_diff {
    my $self = shift;
    my $block = shift;

    my $bound_lt = $self->{$block}{size}[0];
    my $bound_rd = $self->{$block}{size}[1];

    my $array = $self->{data_print};

    my $diff = {};
    my $old_data_print = $self->{old_data_print};
    for (my $y = $bound_lt->[$Y]; $y < $bound_rd->[$Y]; $y++) {
        my $key_glob;
        for (my $x = $bound_lt->[$X]; $x < $bound_rd->[$X]; $x++) {
            my $symbol = $array->[$y][$x]->{symbol};
            my $color = $array->[$y][$x]->{color};
            my $key = "$y,$x";
            if ($symbol eq $old_data_print->[$y][$x]->{symbol}
               and $color eq $old_data_print->[$y][$x]->{color}
            ) {
                $key_glob = $key;
                next;
            }

            if ($key_glob
                and exists($diff->{$key_glob})
                and $diff->{$key_glob}->{color} eq $color
            ) {
               $key = $key_glob;
            } else {
                $key_glob = $key;
            }
            push(@{$diff->{$key}->{symbol}}, $symbol);
            $diff->{$key}->{color} = $color;
            $self->{old_data_print}->[$y][$x]->{symbol} = $symbol;
            $self->{old_data_print}->[$y][$x]->{color} = $color;
        }
    }
    map { $diff->{$_}->{symbol} = join('', @{$diff->{$_}->{symbol}})} keys %$diff;
    for my $key (keys %$diff) {
        $self->{diff}{$key} = $diff->{$key};
    }
}

sub clean_after_itself {
    my $self = shift;
    my $name = shift;

    my $area = $self->{$name}{size};
    for (my $y = $area->[$LT][$Y]; $y < $area->[$RD][$Y]; $y++) {
        for (my $x = $area->[$LT][$X]; $x < $area->[$RD][$X]; $x++) {
            $self->{data_print}->[$y][$x]->{symbol} = '';
            $self->{data_print}->[$y][$x]->{color} = '';
        }
    }
}

sub _get_size_area_action {
    my $size_interface = shift;
    my $size_area_list_obj = shift;

    my $size_area_action = [];


    $size_area_action->[$LT] = [
        0,
        $size_area_list_obj->[$RD][$X] + 1
    ];
    $size_area_action->[$RD] = [
        $size_area_list_obj->[$RD][$Y],
        $size_interface->[$RD][$X]
    ];

    return $size_area_action;
}

sub _get_size_area_list_obj {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_list_obj = [];


    $size_area_list_obj->[$LT] = [
        0,
        $size_area_map->[$RD][$X] + 1
    ];
    $size_area_list_obj->[$RD] = [
        $size_area_map->[$RD][$Y],
        int( ($size_interface->[$RD][$X] - $size_area_map->[$RD][$X]+1) / 2) + $size_area_map->[$RD][$X]
    ];

    return $size_area_list_obj;
}

sub _get_size_interface {
    return [
        [0, 0],
        [$size_term->[$Y], $size_term->[$X]]
    ];
}

sub _get_size_area_text {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_text = [];

    $size_area_text->[$LT] = [
        $size_area_map->[$RD][$Y] + 1,
        0
    ];
    $size_area_text->[$RD] = [
        $size_interface->[$RD][$Y],
        $size_area_map->[$RD][$X]
    ];

    return $size_area_text;
}

sub _get_size_area_map {
    my $size_interface = shift;

    return [
        [0,0],
        [
            int($size_interface->[$RD][$Y] * 0.7),
            int($size_interface->[$RD][$X] * 0.7)
        ]
    ];
}

sub _get_size_area_inv {
    my $size_interface = shift;
    my $size_area_map  = shift;

    my $size_area_inv = [];

    $size_area_inv->[$LT] = [
        $size_area_map->[$LT][$Y],
        $size_area_map->[$LT][$X]
    ];
    $size_area_inv->[$RD] = [
        $size_area_map->[$RD][$Y],
        $size_area_map->[$RD][$X]
    ];

    return $size_area_inv;
}

sub _get_size_area_bag {
    my $size_interface = shift;
    my $size_area_inv  = shift;

    my $size_area_bag = [];

    $size_area_bag->[$LT] = [
        $size_area_inv->[$LT][$Y],
        $size_area_inv->[$LT][$X]
    ];
    $size_area_bag->[$RD] = [
        $size_area_inv->[$RD][$Y],
        int( $size_area_inv->[$RD][$X] / 3)
    ];

    return $size_area_bag;
}

sub _get_size_area_harness {
    my $size_interface = shift;
    my $size_area_inv  = shift;
    my $size_area_bag  = shift;

    my $size_area_harness = [];

    $size_area_harness->[$LT] = [
        $size_area_bag->[$LT][$Y],
        $size_area_bag->[$RD][$X]+1
    ];
    $size_area_harness->[$RD] = [
        $size_area_inv->[$RD][$Y],
        $size_area_inv->[$RD][$X],
    ];

    return $size_area_harness;
}

1;
