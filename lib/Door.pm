package Door;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);
use Consts;

my $id_inc = 0;

sub new {
    my ($self, $icon, $proto_id, $actions, $coord, $blocker) = @_;

    my $obj_text = Language::get_text($proto_id, 'objects');
    my $name = $obj_text->{name};
    my $desc = Utils::split_text($obj_text->{desc});

    my $door = {
        'icon' => $icon,
        'name' => $name,
        'actions' => $actions,
        'type' => 'door',
        'proto_id' => $proto_id,
        'desc'     => $desc,
        'coord' => $coord,
        'blocker' => $blocker,
    };

    bless($door, $self);

    return $door;
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}

sub get_cord {
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

    $self->{icon} = ICON_CLOSE_DOOR;
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

    $self->{icon} = ICON_OPEN_DOOR;
    $self->{blocker} = 0;

    my $actions = $self->get_actions();
    for (my $i=0; $i < @$actions; $i++) {
        if ($actions->[$i]->get_proto_id() == AC_OPEN) {
            $actions->[$i] = Action->new(AC_CLOSE);
        }
    }

    $self->set_actions($actions);
}

1;
