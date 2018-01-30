package Interface::InvInfo;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);
use Interface::Utils;
use Language;

sub process_inv_info {
    my $interface = shift;

    my $inv = $interface->get_inv_obj();
    my $equipment = $inv->get_equipment();

    my $weight = $inv->get_all_weight() // 0;
    my $max_volume = $equipment->get_max_volume() // 0;
    my $volume = $inv->get_all_volume() // 0;

    my $str_color = 'green';
    if ($volume >= $max_volume) {
        $str_color = 'red';
    }
    my $word_volume = Language::get_inv_info('volume');
    my $word_weight = Language::get_inv_info('weight');

    my $str_volume = "[c=$str_color]" . $volume . '/' . $max_volume . '[/c]';

    my $text = Text->new(undef, "$word_weight: $weight/?\n$word_volume: $str_volume");
    my $area = $interface->get_inv_info->{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('inv_info');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);

    return $text_frame_array;
}

1;
