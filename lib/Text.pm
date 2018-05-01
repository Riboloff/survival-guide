package Text;

use strict;
use warnings;
use utf8;

use Storable qw(dclone);
use JSON;

use lib qw(lib);
use Logger qw(dmp);
use Consts;
use Language;

sub new {
    my ($self, %args) = @_;

    my $file = $args{file};
    my $text = $args{text};

    if (!$text) {
        $file = "text/$file";
        $text = Language::read_json_file_lang($file);
    }
    my $hash = {
        text => $text,
        array => [],
        scroll => 0,
    };

    return (bless $hash, $self);
}

sub add_text {
    my $self = shift;
    my $text = shift;

    $self->{text} .= "\n" . $text;
    $self->{scroll} = 0;

    return;
}

sub inition {
    my $self = shift;
    my $size_area_text = shift;
    my $without_frame = shift;

    my $size_y = $size_area_text->[$RD][$Y] - $size_area_text->[$LT][$Y];
    my $size_x = $size_area_text->[$RD][$X] - $size_area_text->[$LT][$X];
    if (!$without_frame) {
        $size_y -= 2,
        $size_x -= 2,
    }

    my $array = [[]];
    for (my $y = 0; $y < $size_y; $y++) {
        for (my $x = 0; $x < $size_x; $x++) {
            $array->[$y][$x] = {'symbol' => ' ', 'color' => ''};
        }
    }
    $self->{array} = $array;

    return $self;
}

sub get_text_array {
    my $self = shift;
    my $size = shift;

    my $size_y = $size->[$Y];
    my $size_x = $size->[$X];

    my $array = [@{$self->{array}}];
    #my $array = $self->{array};
    my @new_lines = ();
    for my $line (split(/\n/, $self->{text})) {
        my $parse_text = _parse_color($line);

        my $words_array = _split_words($parse_text);
        my $line_size = $size_x;

        my $line_buffer = [];
        for my $word (@$words_array) {
            my $size_word = scalar @$word;
            if ((scalar @$line_buffer + $size_word) <= $line_size) {
                push(@$line_buffer, @$word);
            } else {
                push(@new_lines, $line_buffer);
                $line_buffer = [];
                push(@$line_buffer, @$word);
            }
        }
        push(@new_lines, $line_buffer);

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
        if (@{$array->[$y]} < $size_x) {
            for (my $x = @{$array->[$y]}; $x < $size_x; $x++) {
                $array->[$y][$x] = {'symbol' => ' ', 'color' => ''};
            }
        }
    }

    $self->{array} = $array;

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

sub _split_words {
    my $text_array = shift;

    my $words = [];
    my $word = [];
    for (my $i = 0; $i < @$text_array; ++$i) {
        my $symbol = $text_array->[$i]{symbol};
        push (@$word, $text_array->[$i]);

        if ($symbol =~ /\s/ ) {
            push (@$words, $word);
            $word = [];
        }
    }
    push (@$words, $word);


    return $words;
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
    my $size_area_text = $self->{size_area_text}[$RD][$Y] - $self->{size_area_text}[$LT][$Y] - 2;
    if ($self->{scroll} < $scroll_lines - $size_area_text) {
        $self->{scroll}++;
    }
}

sub set_size_area_text {
    my $self = shift;
    my $interface_text = shift;

    $self->{size_area_text} = $interface_text->{size};
}

1;
