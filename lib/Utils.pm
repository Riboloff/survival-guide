package Utils;

use strict;
use warnings;

use List::Util qw(min max);
use lib qw(lib);

sub clamp {
    my $number = shift;
    my $lower = shift;
    my $upper = shift;

    $number = min($number, $upper);
    $number = max($number, $lower);

    return $number;
}
1;
