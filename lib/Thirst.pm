package Thirst;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Item;
use Consts;
use Language;
use Logger qw(dmp);
use Utils;

sub new {
    my $self = shift;
    my $start_water = shift;

    my $thirst = {
        'water' => $start_water,
        'time_dec_one'  => 3,
    };

    bless($thirst, $self);

    return $thirst;
}

sub get_time_dec_one {
    my $self = shift;

    return $self->{time_dec_one};
}

sub get_water {
    my $self = shift;

    return $self->{water};
}

sub add_water {
    my $self = shift;
    my $water_add = shift;

    my $water = $self->{water};
    $water += $water_add;
    $water = Utils::clamp($water, 0, 100);
    $self->{water} = $water;
}

sub sub_water {
    my $self = shift;
    my $water_sub = shift;

    my $water = $self->{water};
    $water -= $water_sub;
    $water = Utils::clamp($water, 0, 100);
    $self->{water} = $water;
}

1;
