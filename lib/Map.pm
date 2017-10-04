package Map;

use strict;
use warnings;

use Storable qw(dclone);
use Term::ANSIColor;
use Term::ReadKey;
use JSON;
use List::Util qw(max min);

use Logger qw(dmp);

use lib qw/lib/;
use Cell;
use Consts qw($X $Y);

my %maps = ();

sub new {
    my $class = shift;
    my $file_name = shift;

    my $map_txt = "";
    my $map_conf = {};
    {
        local $/;
        open(my $in_file_map, '<:utf8' , "map/$file_name") or die("open file map: $!");
        $map_txt = <$in_file_map>;
        close($in_file_map);

        open(my $in_file_map_conf, '<:utf8' , "map/$file_name.conf") or die("open file map conf: $!");
        my $map_conf_json = <$in_file_map_conf>;
        $map_conf = JSON::from_json($map_conf_json);
        close($in_file_map_conf);
    }
    my $map = [];
    my @lines = split(/\n/, $map_txt);
    for (my $y = 0; $y < @lines; $y++) {
        my @symbols_line = split('', $lines[$y]);
        for (my $x = 0; $x < @symbols_line; $x++ ) {
            my $cell = Cell->new($symbols_line[$x], $map_conf->{"$y,$x"}, "$y,$x");
            $map->[$y][$x] = $cell;
        }
    }

    my $self = bless {map => $map}, $class;
    $maps{$file_name} = $self;

    return $self;
}

sub get_map {
    my $class = shift;
    my $map_name = shift;

    if (exists $maps{$map_name}) {
        return $maps{$map_name};
    }

    $class->new($map_name);
}

sub get_map_static {
    my $self = shift;
    my $character = shift;

    my $map = $self->{map};
    my $map_stat = dclone($map);

    my $map_array = [];
    my $char_coord = $character->get_coord();
    my $radius     = $character->get_radius_visibility();
    my $bound_map = [scalar @$map_stat, scalar @{$map_stat->[0]}];
    my ($top_left, $rigt_down) = _get_area_around($character->get_coord(), $bound_map, $radius);

    for (my $y = 0; $y < @$map_stat; $y++) {
        for (my $x = 0; $x < @{$map_stat->[$y]}; $x++) {
            $map_array->[$y][$x]->{symbol} = ' ';
            $map_array->[$y][$x]->{color} = '';
        }
    }
    for (my $y = $top_left->[$Y]; $y < $rigt_down->[$Y]; $y++) {
        for (my $x = $top_left->[$X]; $x < $rigt_down->[$X]; $x++) {
            my $cell = $map_stat->[$y][$x];

            my $icon = $cell->get_icon;

            if ($icon eq '') {
                $map_array->[$y][$x]->{symbol} = ' ';
                $map_array->[$y][$x]->{color} = '';
            } else {
                $map_array->[$y][$x]->{symbol} = $icon;
                $map_array->[$y][$x]->{color} = $cell->{color} || '';
            }
        }
    }

    $map_array = _placement_character($map_array, $character);

    return $map_array;
}

sub _get_area_around {
    my $coord    = shift;
    my $rd_bound = shift;
    my $radius   = shift;

    my $top_left  = [0, 0];
    my $rigt_down = [0, 0];

    $top_left->[$Y] = max($coord->[$Y] - $radius, 0);
    $top_left->[$X] = max($coord->[$X] - $radius, 0);

    $rigt_down->[$Y] = min($coord->[$Y] + $radius, $rd_bound->[$Y]);
    $rigt_down->[$X] = min($coord->[$X] + $radius, $rd_bound->[$X]);

    return ($top_left, $rigt_down);
}

sub _placement_character {
    my $map = shift;
    my $character = shift;

    my $coord = $character->get_coord();
    my $y = $coord->[$Y];
    my $x = $coord->[$X];
    $map->[$y][$x]->{symbol} = $character->{symbol};
    $map->[$y][$x]->{color} = 'red';

    return $map;
}

#В области с радиусом 1, найти все контейнеры
sub get_objects_nigh {
    my $self = shift;
    my $character = shift;
    my $radius = shift || 1; #Если радиус сделать больше единицы, то лутать можно будет через стены.

    my $coord = $character->get_coord();
    my $map = $self->{map};
    my $objects = [];
    my $cells = [];
    my $left_top = [
        ($coord->[$Y]-$radius > 0) ? $coord->[$Y]-$radius : 0,
        ($coord->[$X]-$radius > 0) ? $coord->[$X]-$radius : 0,
    ];
    my $right_down = [
        ($coord->[$Y]+$radius < @$map) ? $coord->[$Y]+$radius : @$map - 1,
        ($coord->[$X]+$radius < @{$map->[0]}) ? $coord->[$X]+$radius : @{$map->[0]} - 1,

    ];
    for (my $y=$left_top->[$Y]; $y <= $right_down->[$Y]; $y++) {
        for (my $x=$left_top->[$X]; $x <= $right_down->[$X]; $x++) {
            my $type = $map->[$y][$x]->get_type();
            if (
                    $type eq 'Container'
                 or $type eq 'Door'
                 or $type eq 'Stair'
            ) {
                my $container = $map->[$y][$x]->get_obj();
                push(@$objects, $container);
            }
        }
    }

    return $objects;
}

sub get_cell {
    my $self = shift;
    my $coord = shift;

    my $y = $coord->[$Y];
    my $x = $coord->[$X];
    return $self->{map}->[$y][$x];
}

1;
