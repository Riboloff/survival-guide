package Keyboard;

use strict;
use warnings;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use Keyboard::Consts qw($hash_keys);

my $mods = {};

sub get_action {
    my @button = @_;

    my $action = 0;

    my $key = join('_', @button);
    if (ref $hash_keys->{$key} eq 'HASH') {
        ($action) = @{$hash_keys->{$key}}{ keys %$mods};
        $action //= $hash_keys->{$key}{default};
    }
    else {
        $action = $hash_keys->{$key};
    }

    return $action;
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
