package Item;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Consts;
use Logger qw(dmp);
use ReadFile;
use Language;
use Text;

my $id_inc = 0;

sub new {
    my ($self, $proto_id) = @_;

    my $text_hash = Language::get_text($proto_id, 'items');
    my $name = $text_hash->{name};
    my $use_text = $text_hash->{use};
    my $desc = Text->new(undef, $text_hash->{desc});
    my $id = create_new_id();
    my $item = {
        'id'         => $id,
        'name'       => $name,
        'desc'       => $desc,
        'type'       => 'item',
        'proto_id'   => $proto_id,
    };
    get_proto_feature($item);
    $item->{used}{text} = Utils::split_text($use_text);

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

sub get_proto_id {
    my $self = shift;

    return $self->{proto_id};
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
    my $text_obj = shift;

    for my $used_key (keys %{$self->{used}}) {
        my $used_value = $self->{used}{$used_key};
        if ($used_key eq 'add_hp') {
            $char->get_health->add_hp($used_value);
        }
        elsif ($used_key eq 'add_water') {
            $char->get_thirst->add_water($used_value);
        }
        elsif ($used_key eq 'add_food') {
            $char->get_hunger->add_food($used_value);
        }
        elsif ($used_key eq 'sub_hp') {
            $char->get_health->sub_hp($used_value);
        }
        elsif ($used_key eq 'sub_water') {
            $char->get_thirst->sub_water($used_value);
        }
        elsif ($used_key eq 'sub_food') {
            $char->get_hunger->sub_food($used_value);
        }
        elsif ($used_key eq 'text') {
            if ($used_value) {
                $text_obj->add_text(Utils::get_random_line($used_value));
            }
        }
    }

    return;
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
