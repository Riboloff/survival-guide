#!/usr/bin/perl

use strict;
use warnings;

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

#open (STDERR, '>>', 'debug.log');

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
    ReadMode('normal');

    if ($key =~ /^[dDaAwWsS]$/) {
        if (!$inv->{on}) {
            _move($key);
            $process_block->{map} = 1;
            $process_block->{list_obj} = 1;
            $chooser->reset_position();
        }
    }
    if ($key =~ /^[rRfF]$/) {
        _scroll_text($key);
        $process_block->{text} = 1;
    }
    if ($key =~ /^[tTgG]$/) {
        _move_chooser($key);
        my $chooser_block_name = $chooser->{block_name};
        $process_block->{$chooser_block_name} = 1;

    }
    if ($key =~ /^[>]$/) {
        if (!$inv->{on}) {
            $chooser->{block_name} = 'action';
            $chooser->{position}{action} = 0;
            $process_block->{action} = 1;
        }
    }
    if ($key =~ /^[<]$/) {
        if (!$inv->{on}) {
            $chooser->{block_name} = 'list_obj';
            $chooser->{position}{action} = 0;
            $process_block->{list_obj} = 1;
        }
    }
    if ($key =~ /^[Ii]$/) {
        if (!$inv->{on}) {
            $inv->on();
            $chooser->{block_name} = 'inv';
            $chooser->{position}{inv} = 0;
            $process_block->{inv} = 1;
        } else {
            $inv->off();
            $interface->clean_after_itself('inv');
            $chooser->{block_name} = 'list_obj';
$chooser->{position}{inv} = 0;
            $process_block->{all} = 1;
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

    if ($key =~ /^[tT]$/) {
        $chooser->top();
    }
    elsif ($key =~ /^[gG]$/) {
        $chooser->down();
    }

    return;
}
