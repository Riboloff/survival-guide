package Stair;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);

sub new {
    my ($self, $icon, $proto_id, $map_name, $coord_enter, $actions) = @_;

    my $obj_text = Language::get_text($proto_id, 'objects');
    my $name = $obj_text->{name};
    my $desc = Utils::split_text($obj_text->{desc});

    my $stair = {
        'icon' => $icon,
        'name' => $name,
        'actions' => $actions,
        #'type' => 'stair',
        'proto_id' => $proto_id,
        'desc'     => $desc,
        'map_name' => $map_name,
        'coord_enter' => $coord_enter,
    };

    bless($stair, $self);

    return $stair;
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}

sub get_name {
    my $self = shift;

    return $self->{name};
}

sub get_actions {
    my $self = shift;

    return $self->{actions};
}

sub get_desc {
    my $self = shift;
    return Utils::get_random_line($self->{desc});
}

sub get_map_name {
    my $self = shift;

    return $self->{map_name};
}

sub get_coord_enter {
    my $self = shift;

    return $self->{coord_enter};
}

1;
