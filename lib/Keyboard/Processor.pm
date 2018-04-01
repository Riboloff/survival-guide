package Keyboard::Processor;

use strict;
use warnings;

use lib qw/lib/;

use Consts;
use CraftTable;
use Events;
use Logger qw(dmp);


sub enter {
    my ($interface) = @_;
    
    my $chooser   = $interface->get_chooser(); 
    my $character = $interface->get_character(); 
    my $inv       = $interface->get_inv_obj(); 

    my $process_block = {};

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
            _move_item_between_bag($bag_inv, KEYBOARD_MOVE_ITEM_LEFT, $bag_craft_result, $item);

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

    return $process_block;
}


sub _move_item_between_bag {
    my $one_bag = shift;
    my $direct  = shift;
    my $two_bag = shift;
    my $item    = shift;

    unless ($one_bag or $two_bag or $item) {
        return;
    }
    if ($direct eq KEYBOARD_MOVE_ITEM_RIGHT) {
        $one_bag->splice_item($item->get_proto_id);
        $two_bag->put_item($item);
    }
    elsif ($direct eq KEYBOARD_MOVE_ITEM_LEFT) {
        $two_bag->splice_item($item->get_proto_id);
        $one_bag->put_item($item);
    }

    return;
}

sub target_on_off {
    my $interface = shift;

    $interface->get_target->switch();
    Keyboard::set_or_rm_mod('target');

    return {map => 1};
}

sub target_move {
    my $interface = shift;
    my $action    = shift;

    my $process_block = {};
    if ($interface->get_main_block_show_name() eq 'map') {
        my $target = $interface->get_target();
        $target->move($interface->get_map_obj, $action);
        $process_block->{map} = 1;
    }

    return $process_block;
}

sub char_move {
    my $interface = shift;
    my $action    = shift;

    my $chooser   = $interface->get_chooser(); 
    my $character = $interface->get_character();

    my $process_block = {};

    $interface->get_bot_by_id(0)->move_bot($interface);
    $interface->get_bot_by_id(1)->move_bot($interface);
    if ($interface->get_main_block_show_name() eq 'map') {
        if ($character->move($interface->get_map_obj, $action)) {
            my $text_obj = $interface->get_text_obj();
            _change_time(
                $text_obj,
                $character,
                $interface->get_time(),
            );
            $process_block->{needs}   = 1;
            $process_block->{map}     = 1;
            $process_block->{objects} = 1;
            $process_block->{text}    = 1;
        }
        $chooser->reset_all_position();
    }

    return $process_block;
}

sub _change_time {
    my ($text_obj, $character, $current_time) = @_;

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

sub scroll_text {
    my ($interface, $action) = @_;

    my $process_block = {};

    my $text_obj = $interface->get_text_obj();

    if ($action eq KEYBOARD_TEXT_UP) {
        $text_obj->top();
        $process_block->{text} = 1;
    }
    elsif($action eq KEYBOARD_TEXT_DOWN) {
        $text_obj->down();
        $process_block->{text} = 1;
    }

    return $process_block;
}

sub esc {
    my ($interface) = @_;

    $interface->clean_after_itself('map');
    $interface->get_chooser->reset_all_position();

    return {all => 1};
}

sub chooser_move {
    my ($interface, $action) = @_;

    my $chooser = $interface->get_chooser();
    $chooser->move_chooser($action);
    return { $chooser->{block_name}  => 1 };
}

sub move_item {
    my ($interface, $action) = @_;

    my $process_block = {};
    my $chooser = $interface->get_chooser();
    my $show_block = $interface->get_main_block_show_name();
    if ($show_block eq 'looting') {
        _move_item_looting($interface, $action, $chooser);
        $process_block->{looting} = 1;
        $process_block->{text} = 1;
    }
    elsif ($show_block eq 'craft') {
        _move_item_craft($interface, $action, $chooser);
        $process_block->{craft} = 1;
    }
    return $process_block;
}

sub _move_item_looting {
    my $interface = shift;
    my $action = shift;
    my $chooser = shift;

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
        $text_obj->add_text(Language::get_inv_info('volume_max'));
        return;
    }
    if (
            $block_name eq 'looting_bag' and $action eq KEYBOARD_MOVE_ITEM_RIGHT
         or $block_name eq 'loot_list'   and $action eq KEYBOARD_MOVE_ITEM_LEFT
    ) {
        _move_item_between_bag($bag_inv, $action, $bag_cont, $item);
    }

    return;
}

sub _move_item_craft {
    my $interface = shift;
    my $action = shift;
    my $chooser = shift;

    my $craft = $interface->get_craft_obj();

    my $bag_inv   = $craft->get_inv_bag();
    my $bag_place = $craft->get_craft_place_bag();

    my $block_name = $chooser->get_block_name();
    my $chooser_position = $chooser->get_position();
    my $item = $chooser->{list}{$block_name}[$chooser_position]->{item};

    if (
            $block_name eq 'craft_bag'   and $action eq KEYBOARD_MOVE_ITEM_RIGHT
         or $block_name eq 'craft_place' and $action eq KEYBOARD_MOVE_ITEM_LEFT
    ) {
        _move_item_between_bag($bag_inv, $action, $bag_place, $item);
    }

    return;
}

sub create_event_minus {
    my ($interface) = @_;

    my $character = $interface->get_character(); 
    my $current_time = $interface->get_time();

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
    return {};
}

sub used_item {
    my ($interface) = @_;

    my $chooser   = $interface->get_chooser(); 
    my $character = $interface->get_character(); 
    my $inv       = $interface->get_inv_obj(); 

    my $obj = $chooser->get_target_object();
    my $process_block = {};

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

    return $process_block;
}

sub inv {
    my ($interface) = @_;

    my $chooser = $interface->get_chooser(); 

    my $process_block = {};
    if ($interface->get_main_block_show_name() ne 'inv') {
        $chooser->{block_name} = 'inv_bag';
        $chooser->{position}{inv_bag} = 0;
        $process_block->{inv} = 1;
    } else {
        _close_block($interface, $process_block, 'inv');
    }

    return $process_block;
}

sub craft {
    my ($interface) = @_;

    my $chooser = $interface->get_chooser(); 

    my $process_block = {};
    if ($interface->get_main_block_show_name() ne 'craft') {
        my $craft = Craft->new($interface->{inv}{obj}{bag});
        $interface->{craft}{obj} = $craft;
        $chooser->{block_name} = 'craft_bag';
        $process_block->{craft} = 1;
    } else {
        _close_block($interface, $process_block, 'craft');
    }

    return $process_block;
}

sub char {
    my ($interface) = @_;

    my $chooser = $interface->get_chooser(); 

    my $process_block = {};
    if ($interface->get_main_block_show_name() ne 'char') {
        $chooser->{block_name} = 'char_dis';
        $chooser->{position}{char_dis} = 0;
        $process_block->{char} = 1;
    } else {
        _close_block($interface, $process_block, 'char');
    }
    return $process_block;
}

sub _close_block {
    my ($interface, $process_block, $block_name) = @_;

    my $chooser = $interface->get_chooser(); 
    $interface->clean_after_itself($block_name);
    $chooser->{block_name} = 'list_obj';
    $chooser->{position}{inv} = 0;
    $process_block->{all} = 1;
}

sub exit {
    $SIG{INT}->();
}

1;
