package Interface::Char;

use strict;
use warnings;
use utf8;

use Storable qw(dclone);

use Logger qw(dmp);
use Consts;
use Interface::Utils;

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'char';

    my $char_array = [];
    my $main_array = $interface->{data_print};

    my $disease_array = process_disease($interface);
    my $empty_array = process_empty($interface);
    my $desc_array = process_desc_disese($interface);

    my $offset_disease = [
        $interface->get_char_dis->{size}[$LT][$Y] - $interface->get_char->{size}[$LT][$Y],
        $interface->get_char_dis->{size}[$LT][$X] - $interface->get_char->{size}[$LT][$X]
    ];
    my $offset_empty = [
        $interface->get_char_empty->{size}[$LT][$Y] - $interface->get_char->{size}[$LT][$Y],
        $interface->get_char_empty->{size}[$LT][$X] - $interface->get_char->{size}[$LT][$X]
    ];

    my $offset_desc = [
        $interface->get_char_desc->{size}[$LT][$Y] - $interface->get_char->{size}[$LT][$Y],
        $interface->get_char_desc->{size}[$LT][$X] - $interface->get_char->{size}[$LT][$X]
    ];

    my $offset = [
        $interface->get_char->{size}[$LT][$Y],
        $interface->get_char->{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($char_array, $disease_array, $offset_disease);
    Interface::Utils::overlay_arrays_simple($char_array, $empty_array, $offset_empty);
    Interface::Utils::overlay_arrays_simple($char_array, $desc_array, $offset_desc);
    Interface::Utils::overlay_arrays_simple($main_array, $char_array, $offset);
}

sub process_disease {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_position = $chooser->get_position('char_dis');
    my $char = $interface->{character};
    my $diseases = $char->get_disease->get_all_disease();
    my $disease_list = [sort keys %$diseases];
    $chooser_position = Utils::clamp($chooser_position, 0, $#$disease_list);
    $chooser->set_position('char_dis', $chooser_position);
    $chooser->{list}{char_dis} = $disease_list;
    $chooser->{bag}{char_dis} = $diseases;

    my $char_dis_array = dclone($interface->get_char_dis->{array_area});
    my $args = {
        list => $disease_list,
        array => $char_dis_array,
        chooser_position => $chooser_position,
        size_area_frame => $interface->get_char_dis->{size_area_frame},
    };
    $char_dis_array = Interface::Utils::list_to_array_symbols_frame($args);

    return $char_dis_array;
}

sub process_empty {
    my $interface = shift;

    my $char_empty_array = dclone($interface->get_char_empty->{array_area});
    my $args = {
        list => [],
        array => $char_empty_array,
        chooser_position => 999,
        size_area_frame => $interface->get_char_dis->{size_area_frame},
    };
    $char_empty_array = Interface::Utils::list_to_array_symbols_frame($args);
    return $char_empty_array;
}

sub process_desc_disese {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_block_name = $chooser->{block_name};
    my $position_chooser = $chooser->{position}{$chooser_block_name};
    my $disese_name = $chooser->{list}{$chooser_block_name}[$position_chooser];
    my $disese = $chooser->{bag}{$chooser_block_name}{$disese_name};
    dmp($disese);
    return [];
=qw
    if (!defined $item) {
        return [];
    }

    my $text = $item->get_desc();
    my $area = $interface->get_inv_desc_item->{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('desc_item');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);

    return $text_frame_array;
=cut
}

1;
