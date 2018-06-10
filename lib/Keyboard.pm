package Keyboard;

use strict;
use warnings;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use Keyboard::Consts qw($hash_keys);

my $mods = {};

sub get_actions {
    my @button = @_;

    my $actions = [];

    my $key = join('_', @button);
    if (ref $hash_keys->{$key} eq 'HASH') {
        for (@{$hash_keys->{$key}}{ keys %$mods}) {
            push(@$actions, @$_);
        }
        if (!@$actions) {
            $actions = $hash_keys->{$key}{default};
        }
    }
    else {
        $actions = $hash_keys->{$key};
    }

    return $actions;
}

sub set_or_rm_mod {
    my $mod = shift;

    if (exists $mods->{$mod}) {
        delete $mods->{$mod};
    }
    else {
        $mods->{$mod} = 1;
    }
}

1;
