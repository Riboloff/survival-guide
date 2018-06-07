package Language;

use strict;
use warnings;
use utf8;

use JSON;
use lib qw/lib/;
use Consts;
use Logger qw(dmp);
use ReadFile;
use Utils;
use Init;

my $lang = 'ru'; #TODO пока хардкод.
#my $lang = 'en'; #TODO пока хардкод.

sub get_text {
    my $id  = shift;
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
    else {
        $file_name = $id;
    }

    $path .= $dir . '/' . $file_name;

    return read_json_file_lang($path);
}

sub get_cach_file {
    my $path = shift;

    $path =~ s{/}{_}g;
    $path =~ s/^text_//;

    return $Init::init->{text}->{$path};
}

sub put_cach_file {
    my $path = shift;
    my $hash = shift;

    $path =~ s{/}{_}g;
    $path =~ s/^text_//;

    $Init::init->{text}->{$path} = $hash;
}

sub read_json_file_lang {
    my $path = shift;

    if (my $cach = get_cach_file($path)) {
        return $cach;
    }

    my $hash = ReadFile::read_json_file($path);
    put_cach_file($path, $hash);

    return $hash->{$lang} || {};
}

sub get_inv_info {
    my $inv_common = Utils::add_hash(
        get_text('inv', 'inform'),
        get_text('inv_info', 'interface')
    );
    return $inv_common->{$_[0]};
}

sub get_title_block {
    return get_text('title', 'interface')->{$_[0]};
}

sub get_head {
    return get_text('head', 'interface')->{$_[0]};
}

sub get_needs {
    return get_text('needs', 'interface')->{$_[0]};
}

sub get_disease_info {
    return get_text('disease', 'inform')->{$_[0]};
}

sub get_disease {
    return get_text('general', 'disease')->{$_[0]};
}

sub get_open_door_info {
    return get_text('open_door', 'inform')->{$_[0]};
}

1;
