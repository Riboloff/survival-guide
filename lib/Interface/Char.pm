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

    my $offset_disease = [
        $interface->get_char_dis->{size}[$LT][$Y] - $interface->get_char->{size}[$LT][$Y],
        $interface->get_char_dis->{size}[$LT][$X] - $interface->get_char->{size}[$LT][$X]
    ];

    my $offset = [
        $interface->get_char->{size}[$LT][$Y],
        $interface->get_char->{size}[$LT][$X]
    ];

    Interface::Utils::overlay_arrays_simple($char_array, $disease_array, $offset_disease);
    Interface::Utils::overlay_arrays_simple($main_array, $char_array, $offset);
}

sub process_disease {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_position = $chooser->get_position('char_dis');
    my $char = $interface->{character};
    my $diseases = $char->get_disease->get_all_disease();
    my $disease_list = [keys %$diseases];
    $chooser_position = Utils::clamp($chooser_position, 0, $#$disease_list);
    $chooser->set_position('char_dis', $chooser_position);
    $chooser->{list}{char_dis} = $disease_list;

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

1;
