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
    my $weight = $text_hash->{weight};
    my $volume = $text_hash->{volume};
    my $add_volume = $text_hash->{add_volume};
    my $item = {
        'id'       => $id,
        'name'     => $name,
        'desc'     => $desc,
        'proto_id' => $proto_id,
        'used'     => {},
        'type'     => '',
        'weight'   => $weight,
        'volume'   => $volume,
        'add_volume' => $add_volume,
    };
    get_proto_feature($item);
    $item->{used}{text} = Utils::split_text($use_text);

    bless($item, $self);

    return $item;
}

sub create_new_id {
    return $id_inc++;
}

sub get_add_volume {
    my $self = shift;

    return $self->{add_volume};
}

sub get_volume {
    my $self = shift;

    return $self->{volume};
}

sub get_weight {
    my $self = shift;

    return $self->{weight};
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

sub get_slot {
    my $self = shift;

    return $self->{slot};
}

sub get_warm {
    my $self = shift;

    return unless exists $self->{warm};
    return $self->{warm};
}

sub used {
    my $self = shift;

    if (
           $self->get_type() eq 'food'
        or $self->get_type() eq 'medicine'
        or $self->get_type() eq 'charge'
    ) {
        $self->used_food(@_);
    }
}

sub used_food {
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
        elsif ($used_key eq 'deseases') {
            my $disease = '';
            for my $disease_id (@$used_value) {
                if ($disease_id == DE_BLEEDING) {
                    $disease = 'bleeding';
                }
                elsif ($disease_id == DE_PAIN) {
                    $disease = 'pain';
                }
                $char->get_disease->disease_off($disease);
                dmp($);
                my $text_disease_off = Utils::get_random_line(
                                            Language::get_disease_info($disease . '_off')
                                        );
                $text_obj->add_text($text_disease_off);
            }
        }
        elsif ($used_key eq 'inc_radius_visibility') {
            my $inc_radius_visibility = $used_value;
            my $radius_visibility = $char->get_radius_visibility();
            if ($radius_visibility < $inc_radius_visibility) {
                $char->set_radius_visibility($inc_radius_visibility);
            }
        }
        elsif ($used_key eq 'light_switch_off') {
            $char->reset_radius_visibility();
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
