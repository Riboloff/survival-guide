package Container;

use strict;
use warnings;

use utf8;

sub new {
    my ($self, $name, $items, $actions) = @_;

    my $container = {
        'items' => $items,
        'name' => $name,
        'actions' => $actions,
    };

    bless($container, $self);
    
    return $container;
}

sub get_name {
    my $self = shift;

    return $self->{name};
}

sub get_actions {
    my $self = shift;

    return $self->{actions};
}

sub get_items {
    my $self = shift;

    return $self->{items};
}

1;
