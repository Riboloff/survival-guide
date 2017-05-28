package Item;

use strict;
use warnings;

use utf8;

sub new {
    my ($self, $name, $desc) = @_;

    my $item = {
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

sub get_desc {
    my $self = shift;

    return $self->{desc};
}

1;
