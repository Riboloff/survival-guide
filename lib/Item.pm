package Item;

use strict;
use warnings;

use utf8;

sub new {
    my ($self, $name, $type) = @_;

    my $item = {
        'type' => $type,
        'name' => $name,
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

1;
