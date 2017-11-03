#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use List::Util qw(min max);

use lib qw(../lib);
use Printer;
use Consts;

my $array = create_array();
my $center_coord = _get_center($array);
$array->[$center_coord->[$Y]][$center_coord->[$X]]->{symbol} = '.';

=we
my $line  = PointRunLine->new($center_coord, [$size_term->[$Y]-3, 30]);
my $line2 = PointRunLine->new($center_coord, [$size_term->[$Y]-3, 120]);
my $line4 = PointRunLine->new($center_coord, [0, 120]);
my $line3 = PointRunLine->new($center_coord, [0, 30]);
my $line5 = PointRunLine->new($center_coord, [0, 30], 2);
=cut

my @lines = ();

my @points_end = (
    [$size_term->[$Y]-3, 30],
    [$size_term->[$Y]-3, 120],
    [0, 120],
    [0, 30],
);

my $offset = 0;
=we
for (my $i=0; $i < ; $i++) {
    $offset += 3;
    for my $point_end (@points_end) {
        push @lines, PointRunLine->new($center_coord, $point_end, $offset);
    }
}
=cut

while(1) {
    if (@lines < 64) {
        for my $point_end (@points_end) {
            push @lines, PointRunLine->new($center_coord, $point_end, $offset);
        }
    }
    my @points = ();
    for my $point_run_line (@lines) {
        my $coord_star = $point_run_line->set_stars();
        my ($y, $x) = @$coord_star;
        $array->[$y][$x]->{symbol} = '.';
        push(@points, [$y, $x]);
    }

    $array->[$center_coord->[$Y]][$center_coord->[$X]]->{symbol} = '.';
    Printer::print_all($array);
    for my $point (@points) {
        my ($y, $x) = ($point->[$Y], $point->[$X]);
        $array->[$y][$x]->{symbol} = '';
    }
    sleep(1);
    $offset += 0;
}


sub create_array {
    my $array = [[]];

    for (my $y=0; $y < $size_term->[$Y]-2; $y++) {
        for (my $x=0; $x < $size_term->[$X]; $x++) {
            my $symbol = '';
            $array->[$y][$x]->{symbol} = $symbol;
            $array->[$y][$x]->{color} = '';
        }
    }
   
   return $array;
}

sub _get_center {
    my $array = shift;

    my $size = [];
    if (ref $array->[0] eq 'ARRAY') {
        $size->[$Y] = @$array;
        $size->[$X] = @{$array->[0]};
    } else { #Передан не двухмерный массив, а размер массива
        $size = $array;
    }

    return [
        int( $size->[$Y] / 2 ),
        int( $size->[$X] / 2 )
    ];
}

package PointRunLine;

use List::Util qw(min max);
use Data::Dumper;

use lib qw(../lib);
use Printer;
use Consts;

sub new {
    my $class = shift;
    my $coord_from = shift;
    my $coord_to = shift;
    my $start_point = shift;

    my $line = _get_points_lie_in_line($coord_from, $coord_to);

    my $self = {
        line  => $line,
        point => $start_point // 0,
    };
    $self = bless($self, $class);
    
    return $self;
}

sub _get_points_lie_in_line {
    my $coord1 = shift;
    my $coord2 = shift;

    my ($y1, $x1) = @$coord1[$Y,$X];
    my ($y2, $x2) = @$coord2[$Y,$X];
    my $aa = 0;
    my $bb = 0;
    if ($x1 - $x2) {
        #$aa = int( ($y1 - $y2)/($x1 - $x2));
        $aa = ($y1 - $y2)/($x1 - $x2);
    }
    $bb =  $y1 - ($aa*$x1);

    my $points = [];
    if ($aa) {
        #for (my $y = min($y1,$y2); $y <= max($y1,$y2); $y++) {
        if ($y1 <= $y2) {
            for (my $y = $y1; $y <= $y2; $y++) {
                my $x = sprintf('%.0f', ($y - $bb) / $aa );
                if ($x == $coord2->[$X]) {
                    next;
                }
                push(@$points, [$y,$x]);
            }
        }
        else {
            for (my $y = $y1; $y >= $y2; $y--) {
                my $x = sprintf('%.0f', ($y - $bb) / $aa );
                if ($x == $coord2->[$X]) {
                    next;
                }
                push(@$points, [$y,$x]); 
            }
        }
    }
    elsif ($x1 == $x2) {
        for (my $y = min($y1,$y2) + 1; $y < max($y1,$y2); $y++) {
            my $x = $x1;
            push (@$points, [$y, $x]);
        }
    }
    elsif ($y1 == $y2) {
        for (my $x = min($x1,$x2) + 1; $x < max($x1,$x2); $x++) {
            my $y = $y1;
            push (@$points, [$y, $x]);
        }
    }
    
    return $points;
}

sub set_stars {
    my $self = shift;

    my $line = $self->{line};
    my $point = $self->{point};

    my $star = $line->[$point];
    $point++;
    if ($point > $#$line) {
        $point = 0;
    }

    $self->{point} = $point;
    return $star;
}

1;

