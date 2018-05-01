package Logger;

use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(dmp dmp_array);

use Data::Dumper;

$Data::Dumper::Useqq = 1;
{ no warnings 'redefine';
    sub Data::Dumper::qquote {
        my $s = shift;
        
        return "'$s'";
    }
}
#binmode STDOUT, ':encoding(UTF-8)';

sub dmp {
    my $data = shift;

    open(my $INF, '>>', './debug.log');
    print $INF Dumper($data);
    close($INF);

    return 1;
}

sub dmp2 {
    my $data = shift;

    if (ref $data eq 'HASH') {
        for (keys %$data) {
            dmp2($data->{$_});
        }
    }
    elsif (ref $data eq 'ARRAY') {
        for (@$data) {
            dmp2($_);
        }
    }
    else {
        open(my $INF, '>>', './debug.log');
        print $INF $data;
        close($INF);
    }

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
