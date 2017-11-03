package Events;

use strict;
use warnings;

use lib qw/lib/;
use Logger qw(dmp);

my %events = ();
my $id_count = 0;

sub new {
    my $class = shift;
    my $opt   = shift;

    my $id = _get_id();
    my $self = {
        'id'      => $id,
        'timeout' => $opt->{timeout},
        'sub'     => $opt->{sub},
        'sub_opt' => $opt->{sub_opt},

    };

    bless($self, $class);
    $events{$id} = $self;

    return $self;
}

sub _get_id {
    return $id_count++;
}

sub check_timeout {
    my $cur_time = Time::get_current_time();

    for my $event_id (keys %events) {
        my $event = $events{$event_id};
        my $timeout = $event->{timeout};
        if ($cur_time >= $timeout) {
            $event->{sub}->(@{$event->{sub_opt}});
            delete $events{$event_id};
        }
    }
}

1;
