#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Term::ReadKey;
use Data::Dumper;
use Encode;

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
use Keyboard;
use Time;
use Events;
use Bot;

my $map = Map->new('squa');
#my $map = Map->new('second_map');
my $start_coord = [10, 18];
my $character = Character->new($start_coord);

my $chooser = Choouser->new();
#my $text_obj = Text->new('text_test_small');
my $text_obj = Text->new('text_test');
my $inv = $character->get_inv();

my $interface = Interface->new($map, $character, $text_obj, $chooser, $inv);
$text_obj->set_size_area_text($interface->{text});
my $process_block = {};

my $current_time = Time->new( {'speed' => 1} );

$SIG{INT} = sub {ReadMode('normal'); exit(0)};

#my %chars = GetControlChars();
my $bot_tmp = Bot->new([11,20]);
push(@{$interface->{bots}}, $bot_tmp);

while(1) {
    $interface->print($process_block);

    $process_block = {};
    ReadMode('cbreak');
    while( defined (my $key_tmp = ReadKey(-1) )) {};
    my $key = ReadKey(0);

    my @keys = ();
    push @keys, ord $key;
    if (ord $key == 27) {
        while( defined (my $key_yet = ReadKey(-1) )) {
            push @keys, ord $key_yet;
        }
    }
    if (is_change_term_size()) {
        $interface->set_size_all_block();
        $interface->{data_print} = Interface::_data_print_init($interface->{size}, $interface->{map}{size});
        $process_block->{all} = 1;
        next;
    }
    my $buttom = Keyboard::get_button(@keys);
    next unless($buttom);

    if ($buttom eq KEYBOARD_ENTER) {
        _enter();
    }
    elsif ($buttom eq KEYBOARD_BACKQUOTE) {
        ReadMode('normal');
        exit(0);
    }
    elsif (
           $buttom == KEYBOARD_MOVE_LEFT
        or $buttom == KEYBOARD_MOVE_RIGHT
        or $buttom == KEYBOARD_MOVE_UP
        or $buttom == KEYBOARD_MOVE_DOWN

    ) {
        my $array_tmp = [KEYBOARD_MOVE_LEFT, KEYBOARD_MOVE_RIGHT, KEYBOARD_MOVE_UP, KEYBOARD_MOVE_DOWN];
        $bot_tmp->move($interface->get_map_obj, $array_tmp->[int rand @$array_tmp]);
        if ($interface->get_main_block_show_name() eq 'map') {
            if ($character->move($interface->get_map_obj, $buttom)) {
                my $text_obj = $interface->get_text_obj();
                _change_time($text_obj);
                $process_block->{needs}   = 1;
                $process_block->{map}     = 1;
                $process_block->{objects} = 1;
                $process_block->{text}    = 1;
            }
            $chooser->reset_all_position();
        }
    }
    elsif (
           $buttom == KEYBOARD_TEXT_UP
        or $buttom == KEYBOARD_TEXT_DOWN
    ) {
        _scroll_text($key);
        $process_block->{text} = 1;
    }
    elsif (
           $buttom == KEYBOARD_UP
        or $buttom == KEYBOARD_DOWN
    ) {
        $chooser->move_chooser($buttom);
        my $chooser_block_name = $chooser->{block_name};
        $process_block->{$chooser_block_name} = 1;

    }
    elsif ($buttom eq KEYBOARD_ESC) {
        $interface->clean_after_itself('map');
        $chooser->reset_all_position();
        $process_block->{all} = 1;
    }
    elsif ($buttom == KEYBOARD_LEFT) {
        my $show_block = $interface->get_main_block_show_name();
        $show_block = 'objects' if $show_block eq 'map';
        $chooser->left();
        $process_block->{$show_block} = 1;
    }
    elsif ($buttom == KEYBOARD_RIGHT) {
        my $show_block = $interface->get_main_block_show_name();
        $show_block = 'objects' if $show_block eq 'map';
        $chooser->right();
        $process_block->{$show_block} = 1;
    }
    elsif (
           $buttom == KEYBOARD_MOVE_ITEM_RIGHT
        or $buttom == KEYBOARD_MOVE_ITEM_LEFT
    ) {
        my $show_block = $interface->get_main_block_show_name();
        if ($show_block eq 'looting') {
            _move_item_looting($key, $chooser, $interface);
            $process_block->{looting} = 1;
            $process_block->{text} = 1;
        }
        elsif ($show_block eq 'craft') {
            _move_item_craft($key, $chooser, $interface);
            $process_block->{craft} = 1;
        }
    }
    elsif ($buttom == KEYBOARD_MINUS) {
        Events->new(
            {
                timeout => $current_time->get_current_time() + 5,
                sub => sub {
                    my $character = shift;

                    $character->get_health->sub_hp('10');
                    $character->get_hunger->sub_food('20');
                    $character->get_thirst->sub_water('30');
                },
                sub_opt => [$character],
            }
        );
    }
    elsif ($buttom == KEYBOARD_USED) {
        _used_item();
    }
    elsif ($buttom == KEYBOARD_INV) {
        if ($interface->get_main_block_show_name() ne 'inv') {
            $chooser->{block_name} = 'inv_bag';
            $chooser->{position}{inv_bag} = 0;
            $process_block->{inv} = 1;
        } else {
            _close_block('inv');
            next;
        }
    }
    elsif ($buttom == KEYBOARD_CRAFT) {
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
    elsif ($buttom == KEYBOARD_CHAR) {
        if ($interface->get_main_block_show_name() ne 'char') {
            $chooser->{block_name} = 'char_dis';
            $chooser->{position}{char_dis} = 0;
            $process_block->{char} = 1;
        } else {
            _close_block('char');
            next;
        }
    }
    Events::check_timeout();
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
        my $type = $item->get_type();
        if (
               $type eq 'food'
            or $type eq 'medicine'
            or $type eq 'charge'
        ) {
            $item->used($character, $interface->get_text_obj());
        }
        elsif ($type eq 'equipment') {
            my $equip = $interface->get_inv_obj->get_equipment;
            if ($chooser->{block_name} ne 'equipment') {
                if (!$equip->clothe_item($item, $character, $interface->get_text_obj())) {
                   return;
                }
            } else {
                if (!$equip->unclothe_item($item, $character, $interface->get_text_obj())) {
                   return;
                }
            }
        } else {
            return;
        }

        my $proto_id = $item->get_proto_id();
        if ($proto_id eq IT_FLASHLIGHT_OFF) {
            $character->get_inv->get_bag->put_item_proto(IT_FLASHLIGHT_ON);
        }
        elsif ($proto_id eq IT_FLASHLIGHT_ON) {
            $character->get_inv->get_bag->put_item_proto(IT_FLASHLIGHT_OFF);
        }

        my $bag = $chooser->get_bag();
        $bag->splice_item($proto_id);

        my $block_name = $chooser->get_block_name();
        my $parent_block_name = Interface::get_parent_block_name($block_name);
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
        my $action_id = $chooser->{list}{action}[$position]->get_proto_id();
        my $pos = $chooser->{position}{list_obj};
        my $obj = $chooser->{list}{list_obj}[$pos];
        my $text_obj = $interface->get_text_obj();
        if ($action_id == AC_OPEN) {
            if ($obj->get_type eq 'Container') {
                $chooser->{position}{loot_list} = 0;
                $chooser->{position}{bag} = 0;
                $chooser->{block_name} = 'loot_list';
                $process_block->{looting} = 1;
            }
            elsif($obj->get_type eq 'Door') {
                my $door = $obj;
                $door->open($text_obj);
                $process_block->{text} = 1;
                $process_block->{map} = 1;
                $process_block->{objects} = 1;
            }
        }
        elsif ($action_id == AC_WATCH) {
            my $description = $obj->get_desc();
            $text_obj->add_text($description);
            $process_block->{text} = 1;
        }
        elsif ($action_id == AC_CLOSE) {
            if ($obj->get_type eq 'Door') {
                my $door = $obj;
                $door->close();
                $process_block->{map} = 1;
                $process_block->{objects} = 1;
            }
        }
        elsif ($action_id == AC_LOCKPICK) {
            if ($obj->get_type eq 'Door') {
                my $door = $obj;
                my $bag = $interface->get_inv_obj->get_bag();
                $obj->lockpick($bag, $text_obj);
                $process_block->{text} = 1;
                $process_block->{map} = 1;
                $process_block->{objects} = 1;
            }
        }
        elsif ($action_id == AC_DOWN or $action_id == AC_UP) {
            $interface->{map}{obj} = Map->get_map($obj->get_map_name);

            my $coord = $obj->get_coord_enter();
            $character->{coord}[$X] = $coord->[$X];
            $character->{coord}[$Y] = $coord->[$Y];

            $interface->clean_after_itself('map');
            $process_block->{all} = 1;
        }
    }
    elsif ($chooser->{block_name} eq 'craft_result') {
        if ($character->is_enable_craft()) {
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
        } else {
            my $cause = $character->get_cause_no_enable_craft();
            my $text_no_enable_craft = Language::get_disease_info('no_enable_craft_' . $cause);
            $interface->get_text_obj->add_text($text_no_enable_craft);
            $process_block->{text} = 1;
        }
        $process_block->{craft} = 1;
    }
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

    my $chooser_position_list_obj = $chooser->{position}{list_obj};
    my $container = $chooser->{list}{list_obj}[$chooser_position_list_obj];
    my $bag_cont = $container->get_bag();

    my $block_name = $chooser->get_block_name();
    my $chooser_position = $chooser->get_position();
    my $item = $chooser->{list}{$block_name}[$chooser_position]->{item};

    my $inv = $interface->get_inv_obj();
    my $bag_inv = $inv->get_bag();
    my $volume = $inv->get_all_volume();
    my $max_volume = $inv->get_equipment->get_max_volume();
    if ($volume + $item->get_volume() > $max_volume) {
        my $text_obj = $interface->get_text_obj();
        dmp(Language::get_inv_info('volume_max'));
        $text_obj->add_text(Language::get_inv_info('volume_max'));
        return;
    }
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
    my $text_obj = shift;

    my $time = $current_time->inc_time->get_current_time();

    if ($time % $character->get_thirst->get_time_dec_one() == 0) {
        $character->get_thirst->sub_water('1');
    }

    if ($time % $character->get_hunger->get_time_dec_one() == 0) {
        $character->get_hunger->sub_food('1');
    }

    if (
        $character->get_hunger->get_food()  == 0
        and $time % $character->get_health->get_time_dec_one() == 0
    ) {
        $character->get_health->sub_hp('1');
    }

    if (
        $character->get_thirst->get_water() == 0
        and $time % $character->get_health->get_time_dec_one() == 0
    ) {
        $character->get_health->sub_hp('1');
    }
    if (
        $character->get_disease->is_disease('bleeding')
        and $time % $character->get_disease->get_time_dec_one_bleeding() == 0
    ) {
        $character->get_health->sub_hp('1');
        my $score_bleeding = $character->get_disease->get_score('bleeding');
        my $text_bleeding = Utils::get_random_line(
                                Language::get_disease_info('bleeding_' . $score_bleeding)
                            );
        $text_obj->add_text($text_bleeding);
    }
}
