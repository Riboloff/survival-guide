#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Term::ReadKey;

use lib qw/lib/;
use Map;
use Text;
use Interface;
use Consts;
use Logger qw(dmp);
use Choouser;
use Inv;
use Character;
use Craft;
use CraftTable;
use Utils;

my $map = Map->new('squa');
my $start_coord = [10, 18];
my $character = Character->new($start_coord);

my $chooser = Choouser->new();
#my $text_obj = Text->new('text_test_small');
my $text_obj = Text->new('text_test');
my $inv = $character->get_inv();

my $interface = Interface->new($map, $character, $text_obj, $chooser, $inv);
$text_obj->set_size_area_text($interface->{text});
my $process_block = {};
my $time = 0;


while(1) {

    ReadMode('normal');
    $interface->print($process_block);

    $process_block = {};
    ReadMode('cbreak');
    my $key = ReadKey(0);
    ReadMode('normal');

    if (is_change_term_size()) {
        $interface->set_size_all_block();
        $interface->{data_print} = Interface::_data_print_init($interface->{size}, $interface->{map}{size});
        $process_block->{all} = 1;
        next;
    }
    if ($key eq "\n") { #Enter заменить на нормальный сигнал
        _enter();
    }
    if ($key =~ /`/) {
        ReadMode('normal');
        exit(0);
    }
    if ($key =~ /^[dDaAwWsS]$/) {
        if ($interface->get_main_block_show_name() eq 'map') {
            _move($key);
            _change_time();
            $process_block->{needs} = 1;
            $process_block->{map} = 1;
            $process_block->{objects} = 1;
            $chooser->reset_position();
        }
    }
    if ($key =~ /^[rRfF]$/) {
        _scroll_text($key);
        $process_block->{text} = 1;
    }
    if ($key =~ /^[JjKk]$/) {
        _move_chooser($key);
        my $chooser_block_name = $chooser->{block_name};
        $process_block->{$chooser_block_name} = 1;

    }
    if ($key =~ /^[Ll]$/) {
        my $show_block = $interface->get_main_block_show_name();
        if ($show_block eq 'map') {
            $chooser->{block_name} = 'action';
            $chooser->{position}{action} = 0;
            $process_block->{objects} = 1;
        }
        elsif ($show_block eq 'looting') {
            if ($chooser->{block_name} ne 'loot_list') {
                $chooser->{block_name} = 'loot_list';
                $process_block->{looting} = 1;
            }
        }
        elsif ($show_block eq 'inv') {
            if($chooser->{block_name} eq 'inv_bag') {
                $chooser->{block_name} = 'equipment';
                $process_block->{inv} = 1;
            }
        }
        elsif ($show_block eq 'craft') {
            if ($chooser->{block_name} eq 'craft_bag') {
                $chooser->{block_name} = 'craft_place';
                $process_block->{craft} = 1;
            }
            elsif ($chooser->{block_name} eq 'craft_place') {
                $chooser->{block_name} = 'craft_result';
                $process_block->{craft} = 1;
            }
        }
    }
    if ($key =~ /^[Hh]$/) {
        my $show_block = $interface->get_main_block_show_name();
        if ($show_block eq 'map') {
            $chooser->{block_name} = 'list_obj';
            $chooser->{position}{action} = 0;
            $process_block->{objects} = 1;
        }
        elsif ($chooser->{block_name} eq 'equipment') {
            $chooser->{block_name} = 'inv_bag';
            $process_block->{inv} = 1;
        }
        elsif ($show_block eq 'looting') {
            if ($chooser->{block_name} ne 'looting_bag') {
                $chooser->{block_name} = 'looting_bag';
                $process_block->{looting} = 1;
            }
        }
        elsif ($show_block eq 'craft') {
            if ($chooser->{block_name} eq 'craft_result') {
                $chooser->{block_name} = 'craft_place';
                $process_block->{craft} = 1;
            }
            elsif ($chooser->{block_name} eq 'craft_place') {
                $chooser->{block_name} = 'craft_bag';
                $process_block->{craft} = 1;
            }
        }
    }
    if ($key =~ /^[Ii]$/) {
        if ($interface->get_main_block_show_name() ne 'inv') {
            $chooser->{block_name} = 'inv_bag';
            $chooser->{position}{inv_bag} = 0;
            $process_block->{inv} = 1;
        } else {
            _close_block('inv');
            next;
        }
    }
    if ($key =~ /^[><]$/) {
        my $show_block = $interface->get_main_block_show_name();
        if ($show_block eq 'looting') {
            _move_item_looting($key, $chooser, $interface);
            $process_block->{looting} = 1;
        }
        elsif ($show_block eq 'craft') {
            _move_item_craft($key, $chooser, $interface);
            $process_block->{craft} = 1;
        }
    }
    if ($key =~ /^[-]$/) {
       $character->get_health->sub_hp('1');
       $character->get_hunger->sub_food('2');
       $character->get_thirst->sub_water('3');
       $process_block->{needs} = 1;
    }
    if ($key =~ /^[eE]$/) {
        _used_item();
    }

    if ($key =~ /^[cC]$/) {
        if ($interface->get_main_block_show_name() ne 'craft') {
            my $craft = Craft->new($interface->{inv}{obj}{bag});
            $interface->{craft}{obj} = $craft;
            $chooser->{block_name} = 'craft_bag';
            $process_block->{craft} = 1;
        } else {
            _close_block('craft');
            next;
        }
    }
}

sub _used_item {
    my $obj = $chooser->get_target_object();
    if (
        $interface->get_main_block_show_name() ne 'craft'
        and $obj
        and ref $obj eq 'HASH'
        and exists $obj->{item}
    ) {
        my $item = $obj->{item};
        if (
               $item->get_type() eq 'food'
            or $item->get_type() eq 'medicine'
        ) {
            $item->used($character, $interface->get_text_obj());
        }
        elsif ($item->get_type() eq 'equipment') {
            my $equip = $interface->get_inv_obj->get_equipment;
            if (!$equip->clothe_item($item, $character, $interface->get_text_obj())) {
               return;
            }
            #$process_block->{equipment} = 1;
        } else {
            return;
        }

        my $bag = $chooser->get_bag();
        $bag->splice_item($item->get_proto_id());

        my $block_name = $chooser->get_block_name();
        my $parent_block_name = $interface->get_parent_block_name($block_name);
        $process_block->{ $parent_block_name || $block_name } = 1;
        $process_block->{needs} = 1;
        $process_block->{text}  = 1;
    }
}

sub _close_block {
    my $block_name = shift;

    $interface->clean_after_itself($block_name);
    $chooser->{block_name} = 'list_obj';
    $chooser->{position}{inv} = 0;
    $process_block->{all} = 1;
}

sub _enter {
    if ($chooser->{block_name} eq 'action') {
        my $position = $chooser->get_position();
        if ($chooser->{list}{action}[$position]->get_proto_id() == AC_OPEN) {
            my $pos = $chooser->{position}{list_obj};
            my $obj = $chooser->{list}{list_obj}[$pos];
            if ($obj->get_type eq 'container') {
                $chooser->{position}{loot_list} = 0;
                $chooser->{position}{bag} = 0;
                $chooser->{block_name} = 'loot_list';
                $process_block->{looting} = 1;
            }
            elsif($obj->get_type eq 'door') {
                my $map = $interface->get_map_obj();
                my $cell = $map->get_cell($obj->get_cord());
                $cell->{blocker} = 0;
                $cell->{icon} = 'O';
                $process_block->{map} = 1;
            }
        }
        if ($chooser->{list}{action}[$position]->get_proto_id() == AC_WATCH) {
            my $pos = $chooser->{position}{list_obj};
            my $obj = $chooser->{list}{list_obj}[$pos];
            my $description = $obj->get_desc();
            my $text_obj = $interface->{text}{obj};
            $text_obj->add_text($description);
            $process_block->{text} = 1;
        }
    }
    elsif ($chooser->{block_name} eq 'craft_result') {
        my $position = $chooser->get_position();
        my $item = $chooser->{list}{craft_result}[$position]->{item};
        my $bag_inv = $interface->get_inv_obj->get_bag();
        my $bag_craft_result = $interface->get_craft_obj->get_craft_result_bag();
        _move_item_between_bag($bag_inv, '<', $bag_craft_result, $item);

        my $list_ingr_proto_id = $CraftTable::craft_table_local{$item->get_proto_id()};
        for my $ingr_proto_id (keys %$list_ingr_proto_id) {
            my $count = $list_ingr_proto_id->{$ingr_proto_id};
            $inv->rm_bag_items($ingr_proto_id, $count);
        }

        $interface->{craft}{obj} = Craft->new($interface->{inv}{obj}{bag});

        $process_block->{craft} = 1;
    }
}

sub _change_coord {
    my $character = shift;
    my $map_obj = shift;
    my $move = shift;

    my $x = $character->{coord}[$X];
    my $y = $character->{coord}[$Y];

    my $map = $map_obj->{map};

    if ($move eq 'right') {
        if ($x + 1 < @{$map->[$y]}) {
            $x++;
        }
    } elsif ($move eq 'left') {
        if ($x > 0) {
            $x--;
        }
    } elsif ($move eq 'top') {
        if ($y > 0) {
            $y--;
        }
    } elsif ($move eq 'down') {
        if ($y + 1 < @$map) {
            $y++;
        }
    }

    my $cell = $map->[$y][$x];

    if ($cell->{blocker}) {
        return;
    }

    $character->{coord}[$X] = $x;
    $character->{coord}[$Y] = $y;

    return;
}

sub _move {
    my $key = shift;

    my $move = '';
    if ($key =~ /^[dD]$/) {
        $move = 'right';
    }
    elsif ($key =~ /^[aA]$/) {
        $move = 'left';
    }
    elsif ($key =~ /^[wW]$/) {
        $move = 'top';
    }
    elsif ($key =~ /^[sS]$/) {
        $move = 'down';
    }

    _change_coord($character, $map, $move);

    return;
}

sub _scroll_text {
    my $key = shift;

    if ($key =~ /^[rR]$/) {
        $text_obj->top();
    }
    elsif($key =~ /^[fF]$/) {
        $text_obj->down();
    }

    return;
}

sub _move_chooser {
    my $key = shift;

    if ($key =~ /^[Kk]$/) {
        $chooser->top();
    }
    elsif ($key =~ /^[jJ]$/) {
        $chooser->down();
    }

    return;
}

sub _move_item_between_bag {
    my $one_bag = shift;
    my $direct  = shift;
    my $two_bag = shift;
    my $item    = shift;

    unless ($one_bag or $two_bag or $item) {
        return;
    } 
    if ($direct eq '>') {
        $one_bag->splice_item($item->get_proto_id);
        $two_bag->put_item($item);
    }
    elsif ($direct eq '<') {
        $two_bag->splice_item($item->get_proto_id);
        $one_bag->put_item($item);
    }

    return;
}

sub _move_item_looting {
    my $key = shift;
    my $chooser = shift;
    my $interface = shift;

    my $bag_inv = $interface->get_inv_obj->get_bag();

    my $chooser_position_list_obj = $chooser->{position}{list_obj};
    my $container = $chooser->{list}{list_obj}[$chooser_position_list_obj];
    my $bag_cont = $container->get_bag();

    my $block_name = $chooser->get_block_name();
    my $chooser_position = $chooser->get_position();
    my $item = $chooser->{list}{$block_name}[$chooser_position]->{item};
    if (
            $block_name eq 'looting_bag' and $key eq '>'
         or $block_name eq 'loot_list'   and $key eq '<'
    ) {
        _move_item_between_bag($bag_inv, $key, $bag_cont, $item);
    }

    return;
}

sub _move_item_craft {
    my $key = shift;
    my $chooser = shift;
    my $interface = shift;

    my $craft = $interface->get_craft_obj();

    my $bag_inv   = $craft->get_inv_bag();
    my $bag_place = $craft->get_craft_place_bag();

    my $block_name = $chooser->get_block_name();
    my $chooser_position = $chooser->get_position();
    my $item = $chooser->{list}{$block_name}[$chooser_position]->{item};

    if (
            $block_name eq 'craft_bag'   and $key eq '>'
         or $block_name eq 'craft_place' and $key eq '<'
    ) {
        _move_item_between_bag($bag_inv, $key, $bag_place, $item);
    }

    return;
}

sub is_change_term_size {
    my ($wchar_current, $hchar_current) = GetTerminalSize();

    $wchar_current--;
    $hchar_current--;
    if (   $Consts::size_term->[$X] != $wchar_current
        or $Consts::size_term->[$Y] != $hchar_current
    ) {
         $Consts::size_term->[$X] = $wchar_current;
         $Consts::size_term->[$Y] = $hchar_current;

         return 1;
    }

    return;
}

sub _change_time {
    $time++;

    if ($time % $character->get_thirst->get_time_dec_one() == 0) {
        $character->get_thirst->sub_water('1');
    }

    if ($time % $character->get_hunger->get_time_dec_one() == 0) {
        $character->get_hunger->sub_food('1');
    }

    if ($character->get_hunger->get_food()  == 0
        and $time % $character->get_health->get_time_dec_one() == 0
    ) {
        $character->get_health->sub_hp('1');
    }
    if ($character->get_thirst->get_water() == 0
        and $time % $character->get_health->get_time_dec_one() == 0
    ) {
        $character->get_health->sub_hp('1');
    }
}
