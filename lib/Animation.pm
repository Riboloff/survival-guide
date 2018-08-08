package Animation;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);

my $animation;

sub new {
    my $class = shift;

    $animation = {
        list => {},
    };

    return bless($animation, $class);
}

sub get {
    if ($animation) {
        return $animation;
    }

    return Animation->new();
}

sub add {
    my $self = shift;
    my $animation = shift;

    $self->{list}{$animation->{block}} = $animation;
}

sub get_animations {
    my $self = shift;
    my $condition = shift;

    my @out = ();
    for my $animation_key (keys %{$self->{list}}) {
        my $animation = $self->{list}{$animation_key};
        if ($animation->{block} eq $condition->{block}) {
            push(@out, $animation);
        }
    }

    return \@out;
}

1;
