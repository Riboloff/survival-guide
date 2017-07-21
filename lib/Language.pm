package Language;

use strict;
use warnings;
use utf8;

use JSON;
use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use ReadFile;

my $lang = 'ru'; #TODO пока хардкод.
my $tilte_blocks = _get_title_blocks();

sub get_text {
    my $id = shift;
    my $dir = shift;

    my $file_name = '';
    my $path = 'text/';
    if ($dir eq 'objects') {
        $file_name = $Consts::objects_id->{$id};
    }
    elsif ($dir eq 'items') {
        $file_name = $Consts::items_id->{$id};
    }
    elsif ($dir eq 'actions') {
        $file_name = $Consts::actions_id->{$id};
    }

    $path .= $dir . '/' . $file_name;

    return read_json_file_lang($path);
}

sub read_json_file_lang {
    my $path = shift;

    my $hash = ReadFile::read_json_file($path);

    return $hash->{$lang};
}

sub _get_title_blocks {
    my $path = $Consts::text_interface_dir . '/' . 'title';

    return read_json_file_lang($path);
}

sub get_title_block {
    my $block_name = shift;


    return $tilte_blocks->{$block_name};
}

1;
