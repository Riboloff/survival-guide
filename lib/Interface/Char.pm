package Interface::Char;

use strict;
use warnings;
use utf8;

use Storable qw(dclone);

use Consts;
use Interface::Utils;
use Logger qw(dmp);

sub process_block {
    my $interface = shift;

    $interface->{main_block_show} = 'char';

    my %init_window = (
        size => {
            main => $interface->get_char->{size},
            sub => {
                char_dis   => $interface->get_char_dis->{size},
                char_empty => $interface->get_char_empty->{size},
                char_desc  => $interface->get_char_desc->{size},
            }
        }
    );

    my $window = Interface::Window->new(%init_window);
    $window->add_sub_block('char_dis',   process_disease($interface, $window));
    $window->add_sub_block('char_empty', process_empty($interface, $window));
    $window->add_sub_block('char_desc',  process_desc_disease($interface));

    $interface->create_window($window);

    return;
}

sub process_disease {
    my ($interface, $window) = @_;

    my $char = $interface->{character};
    my $diseases = $char->get_disease->get_all_disease();

    my $disease_list = [sort keys %$diseases];
    my $disease_list_translate = [map {Language::get_disease($_)} @$disease_list];

    return $window->create_sub_block_list(
        dclone($interface->get_char_dis),
        'char_dis',
        $interface->{chooser},
        $disease_list,
        $disease_list_translate,
        $diseases
    );
}

sub process_empty {
    my ($interface, $window) = @_;

    return $window->create_sub_block_list(
        dclone($interface->get_char_empty),
        undef,
        undef,
        [],
    );
}

sub process_desc_disease {
    my $interface = shift;

    my $chooser = $interface->{chooser};
    my $chooser_block_name = $chooser->{block_name};
    my $position_chooser = $chooser->{position}{$chooser_block_name};
    return [] unless defined $position_chooser;
    my $disease_name = $chooser->{list}{$chooser_block_name}[$position_chooser];
    return [] unless defined $disease_name;
    my $disease = $chooser->{bag}{$chooser_block_name}{$disease_name};
    return [] unless $disease;

    my $text = $disease->{desc};
    my $area = $interface->get_char_desc->{size};
    my $size_area = Interface::Utils::get_size($area);
    $text->inition($area, 1);
    my $text_array = $text->get_text_array($size_area);
    my $title = Language::get_title_block('char_desc');
    my $text_frame_array = Interface::Utils::get_frame($text_array, $title);

    return $text_frame_array;
}

1;
