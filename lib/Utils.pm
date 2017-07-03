package Utils;

use strict;
use warnings;

use List::Util qw(min max);
use lib qw(lib);

sub clamp {
    my $number = shift;
    my $lower = shift // 0;
    my $upper = shift // 0;

    $number = min($number, $upper);
    $number = max($number, $lower);

    return $number;
}
1;
