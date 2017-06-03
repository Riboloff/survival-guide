package Map;

use strict;
use warnings;

use Storable qw(dclone);
use Term::ANSIColor;
use Term::ReadKey;
use JSON;

use Logger qw(dmp);

use lib qw/lib/;
use Cell;
use Consts qw($X $Y);

#my $X = $Consts::X;
#my $Y = $Consts::Y;

sub new {
    my $self = shift;
    my $file_name = shift;

    my $map_txt = "";
    my $map_conf = {};
    {
        local $/;
        open(my $in_file_map, '<:utf8' , "map/$file_name") or die();
        $map_txt = <$in_file_map>;
        close($in_file_map);

        open(my $in_file_map_conf, '<:utf8' , "map/$file_name.conf") or die();
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

    return (bless {map => $map}, $self);
}

sub get_map_static {
    my $self = shift;
    my $character = shift;

    my $map = $self->{map};
    my $map_stat = dclone($map);
    $map_stat = _placement_character($map_stat, $character);

    my $map_array = [];
    for (my $y = 0; $y < @$map_stat; $y++) {
        for(my $x = 0; $x < @{$map_stat->[$y]}; $x++) {
            my $print = '';
            my $cell = $map_stat->[$y][$x];
            if ($cell->{icon} eq '') {
                $map_array->[$y][$x]->{symbol} = ' ';
                $map_array->[$y][$x]->{color} = '';
            } else {
                $map_array->[$y][$x]->{symbol} = $cell->{icon};
                $map_array->[$y][$x]->{color} = $cell->{color} || '';
            }
        }
    }

    return $map_array;
}

sub _placement_character {
    my $map = shift;
    my $character = shift;

    my $coord = $character->get_coord();
    my $y = $coord->[$Y];
    my $x = $coord->[$X];
    $map->[$y][$x]->{icon} = $character->{symbol};
    $map->[$y][$x]->{color} = 'red';

    return $map;
}

#В области с радиусом 1, найти все контейнеры
sub get_container_nigh {
    my $self = shift;
    my $character = shift;
    my $radius = shift || 1; #Если радиус сделать больше единицы, то лутать можно будет через стены.

    my $coord = $character->get_coord();
    my $map = $self->{map};
    my $containers = [];
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
            if ($map->[$y][$x]->get_type() eq 'Container') {
                my $container = $map->[$y][$x]->get_obj();
                push(@$containers, $container);
            }
        }
    }

    return $containers;
}

1;
