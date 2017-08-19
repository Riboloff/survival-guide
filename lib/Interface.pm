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
use Interface::Objects;
use Interface::Inv;
use Interface::Looting;
use Interface::Size;
use Interface::Needs;
use Interface::Craft;

sub new {
    my $self = shift;
    my $map = shift;
    my $character = shift;
    my $text_obj = shift;
    my $chooser = shift;
    my $inv = shift;

    system('clear');


    my $hash = {
        main_block_show => 'map', #map, looting, inv
        map => {
            obj => $map,
            size => [],
        },
        character => $character,
        size => [],
        data_print  => [],
        old_data_print => [],
        text => {
            obj => $text_obj,
            size => [],
        },
        objects => {
            list_obj => {
                size => [],
            },
            action => {
                size => [],
            },
            size => [],
        },
        chooser => $chooser,
        inv => {
            obj => $inv,
            size => [],
            bag => {
                size => [],
            },
            equipment => {
                size => [],
            },
        },
        looting => {
            size => [],
            bag => {
                size => [],
            },
            loot_list => {
                size => [],
            },
            desc_item => {
                size => [],
            },
        },
        needs => {
            size => [],
        },
        craft => {
            size => [],
            obj => undef,
        }
    };

    set_size_all_block($hash);

    $hash->{data_print} = _data_print_init($hash->{size}, $hash->{map}{size});

    $text_obj->inition($hash->{text}{size});

    return bless($hash, $self);
}

sub _data_print_init {
    my $size_interface = shift;
    my $size_area_map = shift;

    my $array = [];
    my $y_bound_map = $size_area_map->[$RD][$Y];
    my $x_bound_map = $size_area_map->[$RD][$X];

    for my $y (0 .. $size_interface->[$RD][$Y] - 1) {
        for my $x (0 .. $size_interface->[$RD][$X] - 1) {
            $array->[$y][$x]->{symbol} = '';
            $array->[$y][$x]->{color} = '';
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
        Printer::print_all($array);
    } else {
        for my $block (keys %$process_block) {
            if (
                   $block eq 'loot_list'
                or $block eq 'bag'
            ) {
                $block = 'looting';
            }
            elsif (
                   $block eq 'list_obj'
                or $block eq 'action'
            ) {
                $block = 'objects';
            }
            elsif (
                   $block eq 'craft_bag'
                or $block eq 'craft_place'
                or $block eq 'craft_result'
            ) {
                $block = 'craft';
            }

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

    if ($block eq 'all') {
        Interface::Map::process_block($self);
        Interface::Text::process_block($self);
        Interface::Objects::process_block($self);
        Interface::Needs::process_block($self);
    }
    elsif ($block eq 'map') {
        Interface::Map::process_block($self);
    } elsif ($block eq 'text') {
        Interface::Text::process_block($self);
    } elsif ($block eq 'objects') {
        Interface::Objects::process_block($self);
    } elsif ($block eq 'inv') {
        Interface::Inv::process_block($self);
    } elsif ($block eq 'looting') {
        Interface::Looting::process_block($self);
    } elsif ($block eq 'needs') {
        Interface::Needs::process_block($self);
    } elsif ($block eq 'craft') {
        Interface::Craft::process_block($self);
    }
}

sub _get_screen_diff {
    my $self = shift;
    my $block = shift;

    my $bound_lt = $self->{$block}{size}[$LT];
    my $bound_rd = $self->{$block}{size}[$RD];

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

sub get_main_block_show_name {
    my $self = shift;

    return $self->{main_block_show};
}

sub get_block_obj {
    my $self = shift;
    my $name = shift;

    if ($self->get_main_block_show_name eq $name) {
        return $self->{$name}{obj};
    }
    else {
        return $self->{$self->get_main_block_show_name}{$name}{obj};
    }
}

sub set_size_all_block {
    my $self = shift;

    Interface::Size::set_size_all_block($self);
}

sub get_inv {
    my $self = shift;

    return $self->{inv}{obj};
}

sub get_list_obj {
    my $self = shift;

    return $self->{objects}{list_obj};
}

sub get_craft {
    my $self = shift;

    return $self->{craft}{obj};
}

sub get_text {
    my $self = shift;

    return $self->{text}{obj};
}

1;
