package Utils;

use strict;
use warnings;

use List::Util qw(min max);
use Logger qw(dmp);
use lib qw(lib);

sub clamp {
    my $number = shift;
    my $lower = shift // 0;
    my $upper = shift // 0;

    $number = min($number, $upper);
    $number = max($number, $lower);

    return $number;
}

sub split_text {
    my $text = shift;

    my @texts = split(/\|\|/, $text);

    return \@texts;
}

sub get_random_line {
    my $lines = shift;

    my $pos = int rand(@$lines);

    return $lines->[$pos];
}

1;
