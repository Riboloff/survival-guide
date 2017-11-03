package Needs::Temp;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Logger qw(dmp);

sub new {
    my $self = shift;
    my $start_temp = shift;
    my $equip = shift;

    my $temp = {
        'temp_out' => $start_temp,
        'bonus_equip' => 0,
        'equip' => $equip,
    };
    bless($temp, $self);
    $temp->_calcul_bonus_equip();
    return $temp;
}

sub set_temp_out {
    my $self = shift;
    my $temp = shift;

    $self->{temp_out} = $temp;
}

sub get_temp_result {
    my $self = shift;

    $self->_calcul_bonus_equip();
    #$self->_calcul_bonus_temp_out();

    return $self->{temp_out} + $self->{bonus_equip};
}

sub _calcul_bonus_equip {
    my $self = shift;

    my $equip = $self->{equip};
    my $items = $equip->get_all_items();

    my $warm = 0;
    for my $item (@$items) {
        $warm += $item->get_warm();
    }

    $self->{bonus_equip} = $warm;

    return;
}

sub add_bonus_equip {
    my $self = shift;
    my $bonus = shift;

    $self->{bonus_equip} += $bonus;

    return;
}

1;
