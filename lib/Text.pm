package Text;

use strict;
use warnings;

use Storable qw(dclone);


use lib qw(lib);
use Logger qw(dmp);
use Consts qw($X $Y $LT $RD);

sub new {
    my $self = shift;
    my $file_name = shift;

    my $text = "";
    {
        local $/;
        open(my $in_file_text, '<' , "text/$file_name") or die();
        $text = <$in_file_text>;
        close($in_file_text);
    }
    my $hash = {
        text => $text,
        array => [],
        scroll => 0,
    };

    return (bless $hash, $self);
}

sub inition {
    my $self = shift;
    my $size_area_text = shift;

    my $size_y = $size_area_text->[$RD][$Y] - $size_area_text->[$LT][$Y];
    my $size_x = $size_area_text->[$RD][$X] - $size_area_text->[$LT][$X];

    my $array = [[]];
    for (my $y = 0; $y < $size_y; $y++) {
        for (my $x = 0; $x < $size_x; $x++) {
            $array->[$y][$x] = {'symbol' => ' ', 'color' => ''};
        }
    }
    $self->{array} = $array;
}

sub get_text_array {
    my $self = shift;
    my $size = shift;

    my $size_rd_y = $size->[$RD]->[$Y];
    my $size_rd_x = $size->[$RD]->[$X];

    my $array = $self->{array};

    my @new_lines = ();
    for my $line (split(/\n/, $self->{text})) {
        my $parse_text = _parse_color($line);

        if (@$parse_text > $size_rd_x) {
            for (0 .. int(@$parse_text/$size_rd_x)) {
                my $new_line = [];
                for (my $x = $_ * $size_rd_x; $x < $size_rd_x * $_ + $size_rd_x; $x++) {
                    if (!defined $parse_text->[$x]) {
                        $parse_text->[$x] = {'color' => '', 'symbol' => ' '};
                    } 
                    push(@$new_line, $parse_text->[$x]);
                }
                push(@new_lines, $new_line);
            }
        } else {
            push(@new_lines, $parse_text);
        }
    }
    for (my $y = 0; $y < @new_lines; $y++) {
        my $line = $new_lines[$y];
        my @symbols = @$line;
        if (!defined $symbols[0]) {
            push (@symbols, {'symbol' => ' ', 'color' => ''});
        }
        for (my $x = 0; $x < @symbols; $x++) {
            $array->[$y][$x] = $symbols[$x];
        }
        if (@{$array->[$y]} < $size_rd_x) {
            for (my $x = @{$array->[$y]}; $x < $size_rd_x; $x++) {
                $array->[$y][$x] = {'symbol' => ' ', 'color' => ''};
            }
        }
    }

    return $array;
}

sub _parse_color {
    my $line = shift;

    my $symbols = [];
    my @arr = split(/(\[c=\w+\].*?)\[\/c\]/, $line);
    for my $sub_lines (@arr) {
        my $color = '';
        my $line_color = $sub_lines;
        if ($sub_lines =~ /^\[c=(\w+)\](.*)$/) {
            $color = $1;
            $line_color = $2;
        }
        for (split(//, $line_color)) {
            push(@$symbols, {'symbol'=> $_, 'color' => $color});
        }
    }
    return $symbols;
}

sub down {
    my $self = shift;

    if ($self->{scroll} > 0) {
        $self->{scroll}--;
    }
}

sub top {
    my $self = shift;

    my $scroll_lines = @{$self->{array}};
    dmp($self->{size_area_text});
    my $size_area_text = $self->{size_area_text}[$RD][$Y] - $self->{size_area_text}[$LT][$Y];
    if ($self->{scroll} < $scroll_lines - $size_area_text) {
        #if ($self->{scroll} < $scroll_lines - 1) {
        $self->{scroll}++;
    }
}

sub set_size_area_text {
    my $self = shift;
    my $interface_text = shift;

    $self->{size_area_text} = $interface_text->{size};
}

1;
