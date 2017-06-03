package Item;

use strict;
use warnings;

use utf8;

sub new {
    my ($self, $name, $desc, $proto_id) = @_;

    my $item = {
        'name'       => $name,
        'desc'       => $desc,
        'type'       => 'item',
        'proto_id'   => $proto_id,
    };

    bless($item, $self);
    
    return $item;
}

sub get_name {
    my $self = shift;

    return $self->{name};
}

sub get_type {
    my $self = shift;

    return $self->{type};
}

sub get_desc {
    my $self = shift;

    return $self->{desc};
}

1;
