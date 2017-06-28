package ReadFile;

use strict;
use warnings;
use utf8;

use JSON;
use lib qw/lib/;
use Consts;
use Logger qw(dmp);

sub read_json_file {
    my $path = shift;

    local $/;
    open(my $in_file, '<:utf8', "$path") or return;
    my $json = <$in_file>;
    close($in_file);
    my $hash = JSON::from_json($json);

    return $hash;
}

1;
