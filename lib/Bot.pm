package Bot;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use base 'Character';

sub new {
    my $self = shift;
    my $start_coord = shift;

    my $bot = {
        coord => $start_coord,
        symbol => '?',
        color => 'blue',
    };

    bless($bot, $self);

    return $bot;
}

sub get_color {
    my $self = shift;

    return $self->{color};
}

#sub move {
#(...)
#}

1;
