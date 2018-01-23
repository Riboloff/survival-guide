package Needs::Disease;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Logger qw(dmp);
use Text;

sub new {
    my $class = shift;

    my $self = {
        bleeding => {
            true => 1,
            time_dec_one => 5,
            desc => Text->new('disease/bleeding', undef),
        },
    };

    bless($self, $class);

    return $self;
}

sub is_bleeding {
    my $self = shift;

    return $self->{bleeding}{true};
}

sub get_time_dec_one_bleeding {
    my $self = shift;

    return $self->{bleeding}{time_dec_one};
}

sub bleeding_off {
    my $self = shift;

    $self->{bleeding}{true} = 0;
}

sub get_all_disease {
    my $self = shift;

    my @keys_disease =  grep {$self->{$_}->{true}} keys %$self;

    my $diseases_true = {};
    for my $disease (@keys_disease) {
        $diseases_true->{$disease} = $self->{$disease};
    }
    return $diseases_true;
}

1;
