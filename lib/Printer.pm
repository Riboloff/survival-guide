package Printer;

use strict;
use warnings;

use Storable qw(dclone);

use Term::ANSIColor;
#use Term::ANSIColor 4.00;
$Term::ANSIColor::AUTORESET = 1;

use Term::Cap;
use POSIX;
use Term::ANSIScreen;

binmode(STDOUT, ":utf8");

use lib qw/lib/;
use Consts qw($X $Y $size_term $LT $RD);
use Logger qw(dmp);


$| = 1;

my $console = Term::ANSIScreen->new;

sub print_diff {
    my $diff = shift;

    for my $yx (sort keys %$diff) {
        my ($y, $x) = split(/,/, $yx);
        $console->Cursor($x, $y);
        print colored(
            $diff->{$yx}->{symbol},
            split(/,/, $diff->{$yx}->{color})
        );
    }

    $console->Cursor(0, $size_term->[$X]);
}

sub print_all {
    my $array = shift;

    $console->Cursor(0, 0);
    for (my $y = 0; $y < @$array; $y++) {
        for (my $x = 0; $x < @{$array->[$y]}; $x++) {
            my $symbol = $array->[$y][$x]->{symbol};
            my $color = $array->[$y][$x]->{color};

            $symbol = " " if (!defined $symbol or $symbol eq '');
            if ($color) {
                print colored($symbol, split(/,/, $color));
            } else {
                print $symbol;
            }
        }
        print "\n";
    }
}

sub print_all_block {
    my $array = shift;
    my $bound = shift;

    my $bound_lt = $bound->[$LT];
    my $bound_rd = $bound->[$RD];

    for (my $y = $bound_lt->[$Y]; $y < $bound_rd->[$Y]; $y++) {
        my $line_array = $array->[$y];
        my @symbol_same_color_in_line = ();
        my $color_same = $line_array->[$bound_lt->[$X]]->{color};
        my $xx = $bound_lt->[$X];
        for (my $x = $bound_lt->[$X]; $x < $bound_rd->[$X]; $x++) {
            my $color  = $line_array->[$x]->{color};
            my $symbol = $line_array->[$x]->{symbol};
            if ($color eq $color_same) {
                push(@symbol_same_color_in_line, $symbol);
            }
            else {
                my $line = join('', @symbol_same_color_in_line);
                $console->Cursor($xx, $y);
                @symbol_same_color_in_line = ();
                push(@symbol_same_color_in_line, $symbol);

                if ($color_same) {
                    print colored($line, split(/,/, $color_same));
                } else {
                    print $line;
                }
                $color_same = $color;
                $xx = $x;
            }
        }
        $console->Cursor($xx, $y);
        my $line = join('', @symbol_same_color_in_line);
        if ($color_same) {
            print colored($line, split(/,/, $color_same));
        } else {
            print $line;
        }
    }
}

sub print_animation {
    my $array = shift;
    my $bound = shift;

    my $bound_lt = $bound->[$LT];
    my $bound_rd = $bound->[$RD];

    for (my $y = 0; $y < @$array; $y++) {
        my $line_array = $array->[$y];
        my @symbol_same_color_in_line = ();
        my $color_same = $line_array->[$bound_lt->[$X]]->{color};
        my $xx = $bound_lt->[$X];
        for (my $x = 0; $x < @{$array->[$y]}; $x++) {
            my $color  = $line_array->[$x]->{color};
            my $symbol = $line_array->[$x]->{symbol};
            if ($color eq $color_same) {
                push(@symbol_same_color_in_line, $symbol);
            }
            else {
                my $line = join('', @symbol_same_color_in_line);
                $console->Cursor($xx + $bound_lt->[$X], $y + $bound_lt->[$Y]);
                @symbol_same_color_in_line = ();
                push(@symbol_same_color_in_line, $symbol);

                if ($color_same) {
                    print colored($line, split(/,/, $color_same));
                } else {
                    print $line;
                }
                $color_same = $color;
                $xx = $x;
            }
        }
        $console->Cursor($xx + $bound_lt->[$X], $y + $bound_lt->[$Y]);
        my $line = join('', @symbol_same_color_in_line);
        if ($color_same) {
            print colored($line, split(/,/, $color_same));
        } else {
            print $line;
        }
    }
}

sub print_animation_text {
    my $array  = shift;
    my $bound  = shift;
    my $offset = shift;

    my $bound_lt = $bound->[$LT];
    my $bound_rd = $bound->[$RD];
    for (my $y = $bound_lt->[$Y]; $y <= $bound_rd->[$Y]; $y++) {
        for (my $x = $bound_lt->[$X]; $x < $bound_rd->[$X]; $x++) {
            my $y_offset = $offset->[$Y] + $y;
            my $x_offset = $offset->[$X] + $x;
            $console->Cursor($x_offset, $y_offset);
            my $symbol = $array->[$y][$x]->{symbol};
            my $color = $array->[$y][$x]->{color};
            print colored($symbol, split(/,/, $color));
        }
    }
}

sub print_icon {
    my $icon = shift;
    my $coord = shift;

    $console->Cursor($coord->[$X], $coord->[$Y]);
    my $symbol = $icon->{symbol};
    my $color   = $icon->{color};
    print colored($symbol, split(/,/, $color));
}

1;
