package Action;

use strict;
use warnings;

use utf8;

my $id_inc = 0;

sub new {
    my ($self, $name, $proto_id) = @_;

    my $container = {
        'name' => $name,
        'type' => 'action',
        'proto_id' => $proto_id,
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

sub get_proto_id {
    my $self = shift;

    return $self->{proto_id};
}

1;
