package CraftTable;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Logger qw(dmp);
use Consts;

our %craft_table_local = (
    Consts::IT_SOFT_BREAD => {
        Consts::IT_BREAD => 1,
        Consts::IT_WATER => 1,
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
