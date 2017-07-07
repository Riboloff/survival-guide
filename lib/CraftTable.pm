package CraftTable;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Logger qw(dmp);
use Consts;

my %craft_table_local = (
    Consts::SOFT_BREAD => [Consts::BREAD, Consts::WATER], 
);

our %craft_table = ();
_create_hash_craft_table();

sub _create_hash_craft_table {
    for my $key (keys %craft_table_local) {
        my $ingredients = join('_', sort @{$craft_table_local{$key}});
        $craft_table{$ingredients} = [$key];
    }
}



1;
