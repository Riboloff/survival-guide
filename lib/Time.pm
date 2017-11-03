package Time;

use strict;
use warnings;

use lib qw/lib/;
use Logger qw(dmp);

my $current_time = 0;

sub new {
    my $class = shift;
    my $opt   = shift;

    my $self = {
        'speed' => $opt->{speed},
        'current_time' => $current_time,
    };

    bless($self, $class);

    return $self;
}

sub inc_time {
    my $self = shift;

    $current_time += $self->{speed};
    $self->{current_time} = $current_time;

    return $self;
}

sub get_current_time {
    my $self = shift;

    if (ref $self) {
        return $self->{current_time};
    } else {
        return $current_time,
    }
}

1;
