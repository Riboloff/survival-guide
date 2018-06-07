package Init;

use strict;
use warnings;

use utf8;

use lib qw(lib);

use Consts;
use Logger qw(dmp);
use ReadFile;
use Language;
use Utils;
use File::Find;

our $init = {};

sub new {
    my $class = shift;

    bless($init, $class);

    $init->start();
}

sub start {
   my $self = shift;

   $self->init_proto_items();
   $self->init_text();
}

sub init_proto_items {
    my $self = shift;

    my $items = {};
    for my $item_key (keys %$Consts::items_id) {
        my $file_name = $Consts::items_id->{$item_key};
        $items->{$item_key} = ReadFile::read_json_file('proto/items/' . $file_name);
    }
    $self->{items} = $items;

    return;
}

sub init_text {
    my $self = shift;

    my @list_paths = ();
    find (sub {
        if (-f) {
            my $path = $File::Find::name;
            push(@list_paths, $File::Find::name);
        }

    }, ('text'));

    for my $path (@list_paths) {
        my $key = $path;
        $key =~ s{/+?}{_}g;
        $key =~ s/^text_//;
        $self->{text}{$key} = Language::read_json_file_lang($path);
    }

    return;
}

1;
