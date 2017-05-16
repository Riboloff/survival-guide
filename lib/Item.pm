package Item;

use strict;
use warnings;

use utf8;

sub new {
    my ($self, $name, $type, $desc) = @_;

    my $item = {
        'type' => $type,
        'name' => $name,
        'desc' => $desc,
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
