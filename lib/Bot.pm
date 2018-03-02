package Bot;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use base 'Character';

my $id = 0;

sub new {
    my $self = shift;
    my ($start_coord, $symbol, $color) = @_;

    my $bot = {
        coord => $start_coord,
        symbol => $symbol // '?',
        color => $color // 'blue',
        id    => create_id(),
    };

    bless($bot, $self);

    return $bot;
}

sub get_color {
    my $self = shift;

    return $self->{color};
}

sub get_id {
    my $self = shift;

    return $self->{id};
}

sub create_id {
    return $id++;
}

1;
