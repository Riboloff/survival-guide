package Map;

use strict;
use warnings;

use Storable qw(dclone);
use Term::ANSIColor;
use Term::ReadKey;

use Logger qw(dmp);

use lib qw/lib/;
use Cell;
use Consts qw($X $Y);

my $X = $Consts::X;
my $Y = $Consts::Y;

sub new {
    my $self = shift;
    my $file_name = shift;

    my $map_txt = "";
    {
        local $/;
        open(my $in_file_map, '<:utf8' , "map/$file_name") or die();
        $map_txt = <$in_file_map>;
        close($in_file_map);
    }
    my $map = [];

    my @lines = split(/\n/, $map_txt);
    for (my $y = 0; $y < @lines; $y++) {
        my @symbols_line = split('', $lines[$y]);
        for (my $x = 0; $x < @symbols_line; $x++ ) {
            my $cell = Cell->new($symbols_line[$x]);
            $map->[$y][$x] = $cell;
        }
    }

    return (bless {map => $map}, $self);
}

sub get_map_static {
    my $self = shift;
    my $moving_obj = shift; 
    my $map = $self->{map};

    my $map_stat = dclone($map);
    $map_stat = _placement_moving_obj($map_stat, $moving_obj);

    my $map_array = [];
    for (my $y = 0; $y < @$map_stat; $y++) {
        for(my $x = 0; $x < @{$map_stat->[$y]}; $x++) {
            my $print = '';
            my $cell = $map_stat->[$y][$x];
            if ($cell->{element} eq '') {
                $map_array->[$y][$x]->{symbol} = ' ';
                $map_array->[$y][$x]->{color} = '';
            } else {
                $map_array->[$y][$x]->{symbol} = $cell->{element};
                $map_array->[$y][$x]->{color} = $cell->{color} || '';
            }
        }
    }

    return $map_array;
}

sub _placement_moving_obj {
    my $map = shift;
    my $moving_obj = shift; 

    for my $symbol (keys %$moving_obj) {
        my $y = $moving_obj->{$symbol}->[$Y];
        my $x = $moving_obj->{$symbol}->[$X];
        $map->[$y][$x]->{element} = $symbol;
        $map->[$y][$x]->{color} = 'red';
    }

    return $map;
}

#В области с радиусом 1, найти все контейнеры
sub get_container_nigh {
    my $self = shift;
    my $coord = shift;
    my $radius = shift || 1; #Если радиус сделать больше единицы, то лутать можно будет через стены.

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
