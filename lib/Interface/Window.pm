package Interface::Window;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;
use Interface::Utils;
use Printer;
use Time::HiRes qw/usleep/;

sub new {
    my $class = shift;
    my (%data) = @_;

    my $self = bless(
        {
            size => $data{size},
            array => [],
        },
        $class
    );

    return $self;
}

sub add_sub_block {
    my ($self, $sub_block, $data_array) = @_;

    my $offset = $self->get_offsets($sub_block);
    Interface::Utils::overlay_arrays_simple($self->{array}, $data_array, $offset);

    return $self;
}

sub get_offsets {
    my ($self, $sub_block) = @_;

    my $main_block = $self->{block};

    return [
        $self->{size}{sub}{$sub_block}[$LT][$Y] - $self->{size}{main}[$LT][$Y],
        $self->{size}{sub}{$sub_block}[$LT][$X] - $self->{size}{main}[$LT][$X]
    ];
}

sub animation_appearance_top {
    my $self = shift;

    my $animation_array = $self->{array};
    my @new = ();
    while (my $string = pop @$animation_array) {
        unshift(@new, $string);
        Printer::print_animation(\@new, [[2,0], [scalar @new, scalar @$string ]]);
        usleep(5000);
    }
}

1;
