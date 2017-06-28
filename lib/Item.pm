package Item;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Consts;
use Logger qw(dmp);
use ReadFile;

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
    get_proto_feature($item);

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
    elsif ($proto_id == Consts::BREAD) {
        $char->get_health->add_hp(3);
        $char->get_hunger->add_food(15);
        $char->get_thirst->sub_water(5);
    }
    elsif ($proto_id == Consts::WATER) {
        $char->get_health->add_hp(1);
        $char->get_thirst->add_water(15);
    }
}

sub get_proto_feature {
    my $item = shift;

    my $file_name = $Consts::items_id->{$item->{proto_id}};

    my $hash = ReadFile::read_json_file($item_dir . $file_name);

    for my $key (keys %$hash) {
        $item->{$key} = $hash->{$key};
    }
}

1;
