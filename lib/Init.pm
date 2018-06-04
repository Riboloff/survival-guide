package Init;

use strict;
use warnings;

use utf8;

use lib qw(lib);

use Consts;
use Logger qw(dmp);
use ReadFile;

our $init = {};

sub new {
    my $class = shift;

    bless($init, $class);

    $init->start();

    dmp($init);
}

sub start {
   my $self = shift;

   $self->init_items();
}

sub init_items {
    my $self = shift;

    my $items = {};
    for my $item_key (keys %$Consts::items_id) {
        my $file_name = $Consts::items_id->{$item_key};
        $items->{$item_key} = ReadFile::read_json_file($Consts::item_dir . $file_name);
    }
    $self->{items} = $items;
}

1;
