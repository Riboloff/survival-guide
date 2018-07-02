package Door;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);
use Consts;

my $id_inc = 0;

sub new {
    my $self = shift;
    my $args = shift;

    my $obj_text = Language::get_text($args->{proto_id}, 'objects');
    my $name = $obj_text->{name};
    my $desc = Utils::split_text($obj_text->{desc});
    my $look = $obj_text->{look};

    my $door = {
        type => 'Door',
        desc => $desc,
        name => $name,
        look => $look,
        %$args,
    };
    bless($door, $self);

    return $door;
}

sub get_look {
    my $self = shift;

    return $self->{look};
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}

sub get_coord {
    my $self = shift;

    return $self->{coord};
}

sub get_name {
    my $self = shift;

    return $self->{name};
}

sub get_type {
    my $self = shift;

    return $self->{type};
}

sub get_actions {
    my $self = shift;

    return $self->{actions};
}

sub get_desc {
    my $self = shift;
    return Utils::get_random_line($self->{desc});
}

sub set_actions {
    my $self = shift;
    my $actions = shift;

    $self->{actions} = $actions;
}

sub close {
    my $self = shift;

    $self->{icon}{symbol} = ICON_CLOSE_DOOR;
    $self->{blocker} = 1;

    my $actions = $self->get_actions();
    for (my $i=0; $i < @$actions; $i++) {
        if ($actions->[$i]->get_proto_id() == AC_CLOSE) {
            $actions->[$i] = Action->new(AC_OPEN);
        }
    }

    $self->set_actions($actions);
}

sub open {
    my $self = shift;
    my $text_obj = shift;

    if ($self->{lockpick}) {
        $text_obj->add_text(Language::get_open_door_info('open_false'));
        return;
    }
    $self->{icon}{symbol} = ICON_OPEN_DOOR;
    $self->{blocker} = 0;

    my $actions = $self->get_actions();
    for (my $i=0; $i < @$actions; $i++) {
        if ($actions->[$i]->get_proto_id() == AC_OPEN) {
            $actions->[$i] = Action->new(AC_CLOSE);
        }
    }

    $self->set_actions($actions);
}

sub lockpick {
    my $self = shift;
    my $bag = shift;
    my $text_obj = shift;

    if ($bag->has_item(IT_LOCKPICK)) {
        $self->{icon}{color} = 'green';
        $self->{lockpick} = 0;
        $text_obj->add_text(Language::get_open_door_info('lockpick_true'));
    } else {
        $text_obj->add_text(Language::get_open_door_info('hasnot_lockpick'));
    }

    return 0;
}

1;
