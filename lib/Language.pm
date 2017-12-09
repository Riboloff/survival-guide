package Language;

use strict;
use warnings;
use utf8;

use JSON;
use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use ReadFile;

my $lang = 'en'; #TODO пока хардкод.

my $tilte_blocks = _get_text_lang($Consts::text_interface_dir, 'title');
my $inv_info = _get_text_lang($Consts::text_interface_dir, 'inv_info');
my $needs = _get_text_lang($Consts::text_interface_dir, 'needs');

my $diseases = _get_text_lang($Consts::text_inform_dir, 'disease');
my $head = _get_text_lang($Consts::text_interface_dir, 'head');

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

sub _get_text_lang {
    my $dir = shift;
    my $file_name = shift;

    my $path = $dir . '/' . $file_name;

    return read_json_file_lang($path);
}

sub get_title_block {
    my $block_name = shift;

    return $tilte_blocks->{$block_name};
}

sub get_head {
    my $block_name = shift;

    return $head->{$block_name};
}

sub get_inv_info {
    my $block_name = shift;

    return $inv_info->{$block_name};
}

sub get_needs {
    my $block_name = shift;

    return $needs->{$block_name};
}

sub get_disease {
    my $disease_name = shift;

    return $diseases->{$disease_name};
}

1;
