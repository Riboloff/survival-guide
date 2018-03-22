package Target;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);

sub new {
    my $class = shift;

    my $target = {
        position => [10, 10],
        symbol => 'X',
        color => 'red',
        visible => 0,
    };

    bless($target, $class);

    return $target;
}

sub switch {
    my $self = shift;

    $self->{visible} = $self->{visible} ? 0 : 1;
}

sub get_position {
    my $self = shift;

    return $self->{position};
}

sub get_symbol {
    my $self = shift;

    return $self->{symbol};
}

sub get_color {
    my $self = shift;

    return $self->{color};
}

sub move {
    my $self = shift;
    my $map_obj = shift;
    my $move = shift;
    
    my $map = $map_obj->{map};
    my $x = $self->{position}[$X];
    my $y = $self->{position}[$Y];

    if ($move == KEYBOARD_TARGET_RIGHT) {
        if ($x + 1 < @{$map->[$y]}) {
            $x++;
        }
    }
    elsif ($move == KEYBOARD_TARGET_LEFT) {
        if ($x > 0) {
            $x--;
        }
    }
    elsif ($move == KEYBOARD_TARGET_UP) {
        if ($y > 0) {
            $y--;
        }
    }
    elsif ($move == KEYBOARD_TARGET_DOWN) {
        if ($y + 1 < @$map) {
            $y++;
        }
    }
    $self->{position}[$X] = $x;
    $self->{position}[$Y] = $y;

    return 1;
}

1;
