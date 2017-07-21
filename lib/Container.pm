package Container;

use strict;
use warnings;
use utf8;

my $id_inc = 0;

sub new {
    my ($self, $name, $items, $actions, $desc, $proto_id) = @_;

    my $id = create_new_id();

    my $container = {
        'id' => $id,
        'items' => $items,
        'name' => $name,
        'actions' => $actions,
        'type' => 'container',
        'proto_id' => $proto_id,
        'desc'     => $desc,
    };

    bless($container, $self);
    
    return $container;
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

sub get_items {
    my $self = shift;

    return $self->{items};
}

sub get_desc {
    my $self = shift;

    return $self->{desc};
}

sub create_new_id {
    return $id_inc++;
}

sub create_new_desc {
    my $file_desc = shift;
    open(my $inf, '<', "$file_desc");
    return ;
}

1;
