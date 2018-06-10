package Interface::Window;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Consts;
use Interface::Utils;
use Interface::Utils;
use Storable qw(dclone);
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


    my $offset = $self->get_offset($sub_block);
    Interface::Utils::overlay_arrays_simple($self->{array}, $data_array, $offset);

    return $self;
}

sub get_offset {
    my ($self, $sub_block) = @_;

    my $main_block = $self->{block};

    return [
        $self->{size}{sub}{$sub_block}[$LT][$Y] - $self->{size}{main}[$LT][$Y],
        $self->{size}{sub}{$sub_block}[$LT][$X] - $self->{size}{main}[$LT][$X]
    ];
}

sub animation_appearance_top {
    my $self = shift;
    my $inf = shift;

    my $animation_array = dclone $self->{array};
    my @new = ();
    while (my $string = pop @$animation_array) {
        unshift(@new, $string);
        my $offset = [
            $self->{size}{main}->[0],
            [scalar @new, scalar @$string]
        ];
        Printer::print_animation(\@new, $offset);
        usleep(5000);
    }
}

sub create_sub_block_list {
    my ($self, $block, $block_name, $chooser, $list, $list_name, $bag) = @_;

    my $chooser_position = 999;
    if ($chooser) {
        $chooser->{list}{$block_name} = $list;
        if ($bag) {
            $chooser->{bag}{$block_name} = $bag;
        }
        if ($chooser->{block_name} eq $block_name) {
            $chooser_position = $chooser->get_position($block_name);
            $chooser_position = Utils::clamp($chooser_position, 0, $#$list);
            $chooser->set_position($block_name, $chooser_position);
        }
    }

    my $args = {
        list  => $list_name || $list,
        array => dclone($block->{array_area}),
        chooser_position => $chooser_position,
        size_area_frame  => $block->{size_area_frame},
    };

    return Interface::Utils::list_to_array_symbols_frame($args);
}

1;
