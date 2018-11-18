package Utils;

use strict;
use warnings;

use Consts;
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

    if (ref $lines ne 'ARRAY') {
        $lines = split_text($lines);
    }
    my $pos = int rand(@$lines);

    return $lines->[$pos];
}

sub add_hash {
    my $hash_one = shift;
    my $hash_two = shift;

    for my $key (keys %$hash_one) {
        $hash_two->{$key} = $hash_one->{$key};
    }

    return $hash_two;
}

sub create_hash_from_array_obj {
    my $array = shift;

    my $hash = {};
    for (@$array) {
        $hash->{$_->get_id()} = $_;
    }

    return $hash;
}

sub are_coords_nearby {
    my $coord1 = shift;
    my $coord2 = shift;

    return (
            abs($coord1->[$X] - $coord2->[$X]) <= 1
        and abs($coord1->[$Y] - $coord2->[$Y]) <= 1
    );
}

sub get_y_last_char {
    my $text_array = shift;
    
    for my $i (reverse 0 .. $#$text_array) {
        my $row = $text_array->[$i];
        for my $icon (@$row) {
            next if ($icon->{symbol} ~~ FRAME_SYMBOLS);
            if ($icon->{symbol} and $icon->{symbol} ne ' ') {
                return $i;
            }
        }
    }
}

sub eq_coords {
    my ($coord1, $coord2) = @_;

    if (
        $coord1->[$Y] eq $coord2->[$Y]
        and
        $coord1->[$X] eq $coord2->[$X]
    ) {
        return 1;
    }

    return 0;
}


1;
