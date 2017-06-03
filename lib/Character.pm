package Character;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Container;
use Health;

sub new {
    my $self = shift;
    my $start_coord = shift;

    my $start_hp = '23';
    my $character = {
        coord => $start_coord,
        symbol => 'A',
        health => Health->new($start_hp),
    };

    bless($character, $self);

    return $character;
}

sub get_coord {
    my $self = shift;

    return $self->{coord};
}

sub get_health {
    my $self = shift;

    return $self->{health};
}

1;
