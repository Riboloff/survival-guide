package Container;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);
my $id_inc = 0;

sub new {
    my ($self, $icon, $proto_id, $actions, $items_id) = @_;

    my $id = create_new_id();

    my $obj_text = Language::get_text($proto_id, 'objects');
    my $name = $obj_text->{name};
    my $desc = Utils::split_text($obj_text->{desc});
    my $look = $obj_text->{look} // join("\n", @$desc);

    my $container = {
        'icon' => $icon,
        'id' => $id,
        'bag' => Bag->new($items_id),
        'name' => $name,
        'actions' => $actions,
        'type' => 'Container',
        'proto_id' => $proto_id,
        'desc'     => $desc,
        'look' => $look,
    };

    bless($container, $self);

    return $container;
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
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

sub get_bag {
    my $self = shift;

    return $self->{bag};
}

sub get_look {
    my $self = shift;

    return $self->{look};
}

sub get_desc {
    my $self = shift;
    return Utils::get_random_line($self->{desc});
}

sub create_new_id {
    return $id_inc++;
}

1;
