#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Term::ReadKey;

use lib qw/lib/;
use Map;
use Text;
use Interface;
use Consts qw($X $Y);
use Logger qw(dmp);
use Choouser;
use Inv;
use Character;

my $map = Map->new('squa');
#my $map = Map->new('main');
my $start_coord = [10, 18];
my $character = Character->new($start_coord);

my $chooser = Choouser->new();
#my $text_obj = Text->new('text_test_small');
my $text_obj = Text->new('text_test');
my $inv = Inv->new();

my $interface = Interface->new($map, $character, $text_obj, $chooser, $inv);
$text_obj->set_size_area_text($interface->{text});
my $process_block = {};

while() {

    $interface->print($process_block);

    $process_block = {};
    ReadMode('cbreak');
    my $key = ReadKey(0);
    # my $key = ReadKey(-1);
    #ReadMode('normal');

    if (is_change_term_size()) {
        $interface->set_size_all_block();
        $interface->{data_print} = Interface::_data_print_init($interface->{size}, $interface->{map}{size});
        $process_block->{all} = 1;
        next;
    }
    if ($key eq "\n") { #Enter заменить на нормальный сигнал
        _enter();
    }
    if ($key =~ /^[dDaAwWsS]$/) {
        if ($interface->get_main_block_show() eq 'map') {
            _move($key);
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
        my $show_block = $interface->get_main_block_show();
        if ($show_block eq 'map') {
            $chooser->{block_name} = 'action';
            $chooser->{position}{action} = 0;
            $process_block->{objects} = 1;
        } elsif ($show_block eq 'looting') {
            if ($chooser->{block_name} ne 'loot_list') {
                $chooser->{block_name} = 'loot_list';
                $process_block->{looting} = 1;
            }
        }
    }
    if ($key =~ /^[Hh]$/) {
        my $show_block = $interface->get_main_block_show();
        if ($show_block eq 'map') {
            $chooser->{block_name} = 'list_obj';
            $chooser->{position}{action} = 0;
            $process_block->{objects} = 1;
        } elsif ($show_block eq 'looting') {
            if ($chooser->{block_name} ne 'bag') {
                $chooser->{block_name} = 'bag';
                $process_block->{looting} = 1;
            }
        }
    }
    if ($key =~ /^[Ii]$/) {
        if ($interface->get_main_block_show() ne 'inv') {
            $chooser->{block_name} = 'inv';
            $chooser->{position}{inv} = 0;
            $process_block->{inv} = 1;
        } else {
            $interface->clean_after_itself('inv');
            $chooser->{block_name} = 'list_obj';
            $chooser->{position}{inv} = 0;
            $process_block->{all} = 1;
            next;
        }
    }
    if ($key =~ /^[><]$/) {
        my $show_block = $interface->get_main_block_show();
        if ($show_block eq 'looting') {
            _move_item($key, $chooser, $interface);
            $process_block->{looting} = 1;
        }
    }
    if ($key =~ /^[-]$/) {
       $character->get_health->sub_hp('1');
       $character->get_hunger->sub_food('2');
       $character->get_thirst->sub_water('3');
       $process_block->{needs} = 1;
    }
    if ($key =~ /^[eE]$/) {
        my $obj = $chooser->get_target_object();
        if ($obj and $obj->get_type eq 'item') {
            my $item = $obj;
            $item->used($character);
            $process_block->{needs} = 1;
            my $block = $chooser->{block_name};
            $process_block->{$block} = 1;
            _delete_item($chooser, $item);
        }
    }
}

sub _delete_item {
    my $chooser = shift;
    my $item_delete = shift;

    my $items = $chooser->get_target_list() || [];

    for (my $i = 0; $i < @$items; $i++) {
        if ($items->[$i]->{id} eq $item_delete->{id}) {
            splice($items, $i, 1);
            last;
        }
    }
}

sub _enter {
    if ($chooser->{block_name} eq 'action') {
        my $position = $chooser->get_position();
        if ($chooser->{list}{action}[$position]->get_proto_id() == Consts::OPEN) {
           $chooser->{position}{loot_list} = 0;
           $chooser->{position}{bag} = 0;
           $chooser->{block_name} = 'loot_list';
           $process_block->{looting} = 1;
        }
        if ($chooser->{list}{action}[$position]->get_proto_id() == Consts::WATCH) {
           $process_block->{text} = 1;
        }
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

sub _move_item {
    my $key = shift;
    my $chooser = shift;
    my $interface = shift;

    my $bag = $interface->{inv}{obj}{bag};

    my $chooser_position_list_obj = $chooser->{position}{list_obj};
    my $container = $chooser->{list}{list_obj}[$chooser_position_list_obj];

    if ($key eq '>' and $chooser->{block_name} eq 'bag') {
        my $chooser_position_bag = $chooser->{position}{bag};
        my ($item) = splice(@{$bag->{items}}, $chooser_position_bag, 1);
        push(@{$container->{items}}, $item);

    }
    elsif ($key eq '<' and $chooser->{block_name} eq 'loot_list') {
        my $chooser_position_loot_list = $chooser->{position}{loot_list};
        my ($item) = splice(@{$container->{items}}, $chooser_position_loot_list, 1);
        push(@{$bag->{items}}, $item);

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
