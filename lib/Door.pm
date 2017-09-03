package Door;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);
my $id_inc = 0;

sub new {
    my ($self, $proto_id, $actions, $coord) = @_;

    my $obj_text = Language::get_text($proto_id, 'objects');
    my $name = $obj_text->{name};
    my $desc = Utils::split_text($obj_text->{desc});

    my $door = {
        'name' => $name,
        'actions' => $actions,
        'type' => 'door',
        'proto_id' => $proto_id,
        'desc'     => $desc,
        'coord' => $coord,
    };

    bless($door, $self);

    return $door;
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

1;
