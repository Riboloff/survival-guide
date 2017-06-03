package Item;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Consts;

my $id_inc = 0;

sub new {
    my ($self, $name, $desc, $proto_id) = @_;

    my $id = create_new_id();
    my $item = {
        'id'         => $id,
        'name'       => $name,
        'desc'       => $desc,
        'type'       => 'item',
        'proto_id'   => $proto_id,
    };

    bless($item, $self);

    return $item;
}

sub create_new_id {
    return $id_inc++;
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

sub used {
    my $self = shift;
    my $char = shift;

    my $proto_id = $self->{proto_id};
    if ($proto_id == Consts::MEDICINE_BOX) {
        $char->get_health->add_hp(10);
    }
}

1;
