package Health;

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
    my $start_hp = shift;

    my $health = {
        'hp' => $start_hp,
    };

    bless($health, $self);

    return $health;
}

sub get_hp {
    my $self = shift;

    return $self->{hp};
}

sub add_hp {
    my $self = shift;
    my $hp_add = shift;

    my $hp = $self->{hp};
    $hp += $hp_add;
    $hp = Utils::clamp($hp, 0, 100);
    $self->{hp} = $hp;
}

sub sub_hp {
    my $self = shift;
    my $hp_sub = shift;

    my $hp = $self->{hp};
    $hp -= $hp_sub;
    $hp = Utils::clamp($hp, 0, 100);
    $self->{hp} = $hp;
}

1;
