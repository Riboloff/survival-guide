package Printer;

use strict;
use warnings;

use Storable qw(dclone);

#use Term::ANSIColor 4.00 qw(:constants256);
use Term::ANSIColor 4.00;
$Term::ANSIColor::AUTORESET = 1;

use Term::Cap;
use POSIX;
use Term::ANSIScreen;

use Data::Dumper;

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
        for(my $x = 0; $x < @{$array->[$y]}; $x++) {
            my $symbol = $array->[$y][$x]->{symbol};
            my $color = $array->[$y][$x]->{color};

            $symbol = " " if ($symbol eq '');
            if ($color) {
                print colored($symbol, split(/,/, $color));
            } else {
                print $symbol;
            }
        }
        print "\n";
    }
}

sub clean_screen {
    $console->Cursor(0, 0);

    for (my $y = 0; $y <= $size_term->[$Y]; $y++) {
        for(my $x = 0; $x <= $size_term->[$X]; $x++) {
            print " ";
        }
    }
}

sub print_all_block {
    my $array = shift;
    my $bound = shift;

    my $bound_lt = $bound->[$LT];
    my $bound_rd = $bound->[$RD];

    my @lines = ();
    for (my $y = $bound_lt->[$Y]; $y < $bound_rd->[$Y]; $y++) {
        $console->Cursor($bound_lt->[$X], $bound_lt->[$Y] + $y);
        my $line_array = $array->[$y];
        my $line = join('', map{$_->{symbol}} @$line_array[$bound_lt->[$X] .. $bound_rd->[$X]-1]);
        print $line;
    }
}

1;
