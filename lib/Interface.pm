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
use Interface::Char;
use Interface::Head;
use Utils;

=we
use lib './xslib';
use lib './xslib/blib/lib';
use lib './xslib/blib/arch';
use XS::Interface;

my $ll = [[0, 5, 6], [0, 88, 91], [0, 9999, 77777]];
my $tl = [[51, 61], [881, 911]];
print Data::Dumper::Dumper($ll);
print Data::Dumper::Dumper($tl);
XS::Interface::overlay_arrays_simple($ll, $tl, 1, 1);
print Data::Dumper::Dumper($ll);
print Data::Dumper::Dumper($tl);
exit();
=cut

sub new {
    my ($class, $args) = @_;

    my $map       = $args->{map};
    my $character = $args->{character};
    my $text_obj  = $args->{text_obj};
    my $chooser   = $args->{chooser};
    my $inv       = $args->{inv};
    my $bots      = Utils::create_hash_from_array_obj($args->{bots});
    my $target    = $args->{target};

    #system('clear');

    my $hash = {
        main_block_show => 'map', #map, looting, inv
        map => {
            obj => $map,
            size => [],
        },
        character => $character,
        bots => $bots,
        target => $target,
        size => [],
        data_print  => [],
        old_data_print => [],
        text => {
            obj => $text_obj,
            size => [],
        },
        objects => {
            sub_block => {
                list_obj => {
                    size => [],
                    array_area => [],
                },
                action => {
                    size => [],
                },
            },
            size => [],
        },
        chooser => $chooser,
        inv => {
            obj => $inv,
            size => [],
            sub_block => {
                inv_bag => {
                    size => [],
                },
                equipment => {
                    size => [],
                },
                desc_item => {
                    size => [],
                },
            }
        },
        looting => {
            size => [],
            sub_block => {
                looting_bag => {
                    size => [],
                },
                loot_list => {
                    size => [],
                },
                desc_item => {
                    size => [],
                },
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

    my $self = bless($hash, $class);
    $self->initial();
    return $self;
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
        #TODO: Тут хрен. Дочернии и родительские блоки в перемешку!
        #Если процессим родительский, то дочернии нужно пропускать!
        for my $block (keys %$process_block) {
            my $parent_block = get_parent_block_name($block) || $block;

            $self->_process_block($parent_block);
            #TODO Существуют случаи, когда нужно процессить не каждый дочерний, а родительский целиком.
            #При первом открытии нового окна(инвинтарь, крафт).
            #if (my $sub_blocks_names = @{$self->get_sub_blocks_name($parent_block)}) {
            #    for my $sub_block_name (@{$self->get_sub_blocks_name($parent_block)}) {
            #        $self->_get_screen_diff($sub_block_name);
            #    }
            #}
            #else {
                $self->_get_screen_diff($parent_block);
                #}
        }
        $self->_get_screen_diff('head');
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
        Interface::Head::process_block($self);
    }
    elsif ($block eq 'map') {
        Interface::Map::process_block($self);
        Interface::Head::process_block($self);
    } elsif ($block eq 'text') {
        Interface::Text::process_block($self);
    } elsif ($block eq 'objects') {
        Interface::Objects::process_block($self);
    } elsif ($block eq 'inv') {
        Interface::Inv::process_block($self);
        Interface::Head::process_block($self);
    } elsif ($block eq 'craft') {
        Interface::Craft::process_block($self);
        Interface::Head::process_block($self);
    } elsif ($block eq 'char') {
        Interface::Char::process_block($self);
        Interface::Head::process_block($self);
    } elsif ($block eq 'looting') {
        Interface::Looting::process_block($self);
    } elsif ($block eq 'needs') {
        Interface::Needs::process_block($self);
    } elsif ($block eq 'head') {
        Interface::Head::process_block($self);
    }
}

sub _get_screen_diff {
    my $self = shift;
    my $block = shift;

    my $bound_lt = [];
    my $bound_rd = [];

    my $block_data = $self->get_block($block);

    $bound_lt = $block_data->{size}[$LT];
    $bound_rd = [@{$block_data->{size}[$RD]}];
    if (exists $block_data->{size_data}) {
        $bound_lt = $block_data->{size_data}[$LT];
        $bound_rd = $block_data->{size_data}[$RD];
    }
    my $array = $self->{data_print};

    if ($block eq 'head') {
        $bound_rd->[$Y]++ ;
    }

    my $diff = {};
    my $old_data_print = $self->{old_data_print};
    for (my $y = $bound_lt->[$Y]; $y < $bound_rd->[$Y]; $y++) {
        my $key_glob;
        for (my $x = $bound_lt->[$X]; $x < $bound_rd->[$X]; $x++) {
            #my $symbol = $array->[$y][$x]->{symbol} // '';
            #my $color = $array->[$y][$x]->{color} // '';

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

    my $area = $name ? $self->{$name}{size} : $self->{size};
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

sub set_size_all_block {
    my $self = shift;

    Interface::Size::set_size_all_block($self);
}

sub get_inv {
    my $self = shift;

    return $self->{inv};
}

sub get_inv_obj {
    my $self = shift;

    return $self->{inv}{obj};
}

sub get_inv_bag {
    my $self = shift;

    return $self->{inv}{sub_block}{inv_bag};
}

sub get_inv_desc_item {
    my $self = shift;

    return $self->{inv}{sub_block}{desc_item};
}

sub get_inv_info {
    my $self = shift;

    return $self->{inv}{sub_block}{inv_info};
}

sub get_char {
    my $self = shift;

    return $self->{char};
}

sub get_char_dis {
    my $self = shift;

    return $self->{char}{sub_block}{char_dis};
}

sub get_char_empty {
    my $self = shift;

    return $self->{char}{sub_block}{char_empty};
}

sub get_char_desc {
    my $self = shift;

    return $self->{char}{sub_block}{char_desc};
}

sub get_equipment {
    my $self = shift;

    return $self->{inv}{sub_block}{equipment};
}

sub get_list_obj {
    my $self = shift;

    return $self->{objects}{sub_block}{list_obj};
}

sub get_action {
    my $self = shift;

    return $self->{objects}{sub_block}{action};
}

sub get_craft_obj {
    my $self = shift;

    return $self->{craft}{obj};
}

sub get_craft {
    my $self = shift;

    return $self->{craft};
}

sub get_craft_bag {
    my $self = shift;

    return $self->{craft}{sub_block}{bag};
}

sub get_craft_place {
    my $self = shift;

    return $self->{craft}{sub_block}{place};
}

sub get_craft_result {
    my $self = shift;

    return $self->{craft}{sub_block}{result};
}

sub get_needs {
    my $self = shift;

    return $self->{needs};
}

sub get_text {
    my $self = shift;

    return $self->{text};
}

sub get_text_obj {
    my $self = shift;

    return $self->{text}{obj};
}

sub get_objects {
    my $self = shift;

    return $self->{objects};
}

sub get_bot_by_id {
    my $self = shift;
    my $id   = shift;

    return $self->{bots}{$id};
}

sub get_map {
    my $self = shift;

    return $self->{map};
}

sub get_target {
    my $self = shift;

    return $self->{target};
}

sub get_map_obj {
    my $self = shift;

    return $self->{map}{obj};
}

sub get_looting {
    my $self = shift;

    return $self->{looting};
}

sub get_loot_list {
    my $self = shift;

    return $self->{looting}{sub_block}{loot_list};
}

sub get_looting_bag {
    my $self = shift;

    return $self->{looting}{sub_block}{looting_bag};
}

sub get_looting_desc_item {
    my $self = shift;

    return $self->{looting}{sub_block}{desc_item};
}

sub get_head {
    my $self = shift;

    return $self->{head};
}

sub initial {
    my $self = shift;

    for my $block_name (qw/list_obj action objects inv_bag needs char_dis char_empty char_desc/) {
        my $block = $self->get_block($block_name);
        my $title = Language::get_title_block($block_name) || '';
        Interface::Utils::init_array_area($block, $title);
    }
}

sub get_block {
    my $self  = shift;
    my $block_name = shift;

    my $block_obj;
    return unless $block_name;
    my $method_name = 'get_' . $block_name;
    eval{ $block_obj = $self->$method_name};
    return $block_obj;

    return $block_obj;
}

sub get_sub_blocks_name {
    my $self = shift;
    my $parent_block_name = shift;

    return [keys %{$self->{$parent_block_name}{sub_block}}];
}

sub get_parent_block_name {
    my $block_name = shift;

    my $parent_block_name = '';
    if (
           $block_name eq 'loot_list'
        or $block_name eq 'looting_bag'
    ) {
        $parent_block_name = 'looting';
    }
    elsif (
           $block_name eq 'list_obj'
        or $block_name eq 'action'
    ) {
        $parent_block_name = 'objects';
    }
    elsif (
           $block_name eq 'inv_bag'
        or $block_name eq 'equipment'
    ) {
        $parent_block_name = 'inv';
    }
    elsif (
           $block_name eq 'char_dis'
    ) {
        $parent_block_name = 'char';
    }
    elsif (
           $block_name eq 'craft_bag'
        or $block_name eq 'craft_place'
        or $block_name eq 'craft_result'
    ) {
        $parent_block_name = 'craft';
    }

    return $parent_block_name;
}

1;
