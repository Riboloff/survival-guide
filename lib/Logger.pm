package Logger;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(dmp dmp_array);

use Data::Dumper;

sub dmp {
    my $data = shift;

    open(my $INF, '>>', './debug.log');
    print $INF Dumper($data);
    close($INF);

    return 1;
}

sub dmp_array {
    my $data = shift;

    open(my $INF, '>>', './debug.log');
    for my $str (@$data) {
            print $INF join('', map {$_->{symbol}} @$str);
            print $INF "\n";
    }
    close($INF);

    return 1;
}

1
