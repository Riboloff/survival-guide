package Action;

use strict;
use warnings;

use utf8;

my $id_inc = 0;

sub new {
    my ($self, $proto_id) = @_;

    my $hash = Language::get_text($proto_id, 'actions');
    my $name = $hash->{name};
                    
    my $action = {
        'name' => $name,
        'type' => 'action',
        'proto_id' => $proto_id,
    };

    bless($action, $self);
    
    return $action;
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
