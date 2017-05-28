package Language;

use strict;
use warnings;
use utf8;

use JSON;
use lib qw/lib/;
use Consts;
use Logger qw(dmp);

my $path_text = 'text/';

my $lang = 'ru'; #TODO пока хардкод.

sub get_text_object {
    my $id = shift;

    my $obj = {};
    my $file_name = $Consts::objects_id->{$id};
    {
        local $/;
        open(my $in_file_obj, '<:utf8', "$path_text/objects/$file_name");
        my $obj_json = <$in_file_obj>;
        close($in_file_obj);
        $obj = JSON::from_json($obj_json);
    }

    return $obj->{$lang};
}

sub read_json_file {
    my $path = shift;

    local $/;
    open(my $in_file, '<:utf8', "$path");
    my $json = <$in_file>;
    close($in_file);
    my $hash = JSON::from_json($json);

    return $hash->{$lang};
}

1;
