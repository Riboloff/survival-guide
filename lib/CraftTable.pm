package CraftTable;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Logger qw(dmp);
use Consts;

our %craft_table_local = (
    Consts::SOFT_BREAD => {
        Consts::BREAD => 1,
        Consts::WATER => 1,
    },
);

our %craft_table = ();
_create_hash_craft_table();

sub _create_hash_craft_table {
    for my $key (keys %craft_table_local) {
        my @ingredients = sort keys %{$craft_table_local{$key}};
        my $ingredients_str = join('_', @ingredients);
        $craft_table{$ingredients_str}{result} = $key;
        for my $ingr (@ingredients) {
            $craft_table{$ingredients_str}{count}{$ingr} = $craft_table_local{$key}{$ingr};
        }
    }
}



1;
