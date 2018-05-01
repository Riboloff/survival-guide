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
            true => 0,
            time_dec_one => 5,
            score => 1,
            desc => Text->new(file => 'disease/bleeding'),
        },
        pain => {
            true => 0,
            score => 1,
            desc => Text->new(file => 'disease/pain'),
        },
    };

    bless($self, $class);

    return $self;
}

sub get_score {
    my $self= shift;
    my $disease = shift;

    return $self->{$disease}{score};
}

sub is_disease {
    my $self = shift;
    my $disease = shift;

    return $self->{$disease}{true};
}

sub get_time_dec_one_bleeding {
    my $self = shift;

    return int ($self->{bleeding}{time_dec_one} / $self->{bleeding}{score});
}

sub disease_off {
    my $self = shift;
    my $disease = shift;

    $self->{$disease}{true} = 0;
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
