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
use Interface::Utils;

sub new {
    my ($class, %args) = @_;

    my $file = $args{file};
    my $text = $args{text};
    my $area = $args{area};
    my $frame = $args{frame} // 0;

    if (!defined $text and $file) {
        $file = "text/$file";
        $text = Language::read_json_file_lang($file);
    }

    my $hash = {
        text => $text,
        array => [],
        scroll => 0,
    };

    my $self = (bless $hash, $class);

    if ($area) {
        $self->inition($area, $frame);
    }

    return $self;
}

sub add_text {
    my ($self, $text) = @_;

    $self->{text} .= "\n" . $text;
    $self->{scroll} = 0;

    return;
}

sub inition {
    my ($self, $area, $frame) = @_;

    my $size_area;
    if ($area) {
        if ($frame) {
            $size_area = Interface::Utils::get_size($area),
        }
        else {
            dmp(11111111111);
            $size_area = Interface::Utils::get_size_without_frame($area),
        }
        $self->{area} = $area;
        $self->{size_area} = $size_area;
    }


    my $size_y = $area->[$RD][$Y] - $area->[$LT][$Y];
    my $size_x = $area->[$RD][$X] - $area->[$LT][$X];
    if (!$frame) {
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
    my $size = shift || $self->{size_area};

    my $size_x = $size->[$X];

    my $array = [@{$self->{array}}];
    my @new_lines = ();
    for my $line (split(/\n/, $self->{text})) {
        my $parse_text = _parse_color($line);

        my $words_array = _split_words($parse_text);

        my $line_buffer = [];
        for my $word (@$words_array) {
            my $size_word = scalar @$word;
            if ((scalar @$line_buffer + $size_word) <= $size_x) {
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

    unless (Interface::Utils::is_object_into_area($size, $array) ) {
        $array = $self->shift();
    }

    return $array;
}

sub _parse_color {
    my $line = shift;

    my $symbols = [];
    my @arr = split(/(\[c=[A-Za-z,]++\].*?)\[\/c\]/, $line);
    for my $sub_lines (@arr) {
        my $color = '';
        my $line_color = $sub_lines;
        if ($sub_lines =~ /^\[c=([A-Za-z,]++)\](.*)$/) {
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
    my $area = $self->{area}[$RD][$Y] - $self->{area}[$LT][$Y] - 2;
    if ($self->{scroll} < $scroll_lines - $area) {
        $self->{scroll}++;
    }
}

sub shift {
    my $self = shift;

    my $scroll = $self->{scroll};
    my $area = Interface::Utils::get_size_without_frame($self->{area});
    my $text_array = $self->{array};
    my $last_str_number = @$text_array - $scroll - 1;
    my $first_str_number = $last_str_number - ($area->[$Y] - 1);
    my $text_array_chank = [@$text_array[$first_str_number .. $last_str_number]];

    return $text_array_chank;
}

1;
