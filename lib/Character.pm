package Character;

use strict;
use warnings;

use lib qw/lib/;
use Container;
use utf8;

sub new {
    my $self = shift;
    my $start_coord = shift;
    
    my $character = {
        coord => $start_coord,
        symbol => 'A',
    };

    bless($character, $self);

    return $character;
}

sub get_coord {
    my $self = shift;

    return $self->{coord};
}

1;
