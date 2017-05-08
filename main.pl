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

#open (STDERR, '>>', 'debug.log');

my $map = Map->new('squa');
#my $map = Map->new('main');
my $coord = [10, 18];

my $moving_obj = {
    'A' => $coord,
};
my $chooser = Choouser->new();
#my $text_obj = Text->new('text_test_small');
my $text_obj = Text->new('text_test');
my $inv = Inv->new();

my $interface = Interface->new($map, $moving_obj, $text_obj, $chooser, $inv);
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
    if ($key =~ /^[rR]$/) {
        $text_obj->top();
        $process_block->{text} = 1;
    }
    if ($key =~ /^[fF]$/) {
        $text_obj->down();
        $process_block->{text} = 1;
    }
    if ($key =~ /^[tT]$/) {
        $chooser->top();
        if ($chooser->{block_name} eq 'list_obj') {
            $process_block->{list_obj} = 1;
        } elsif ($chooser->{block_name} eq 'action') {
            $process_block->{action} = 1;
        } elsif ($chooser->{block_name} eq 'inv') {
            $process_block->{inv} = 1;
        }
    }
    if ($key =~ /^[gG]$/) {
        $chooser->down();
        if ($chooser->{block_name} eq 'list_obj') {
            $process_block->{list_obj} = 1;
        } elsif ($chooser->{block_name} eq 'action') {
            $process_block->{action} = 1;
        } elsif ($chooser->{block_name} eq 'inv') {
            $process_block->{inv} = 1;
        }
    }
    if ($key =~ /^[>]$/) {
        $chooser->{block_name} = 'action';
        $chooser->{position}{action} = 0;
        $process_block->{action} = 1;
    }
    if ($key =~ /^[<]$/) {
        $chooser->{block_name} = 'list_obj';
        $chooser->{position}{action} = 0;
        $process_block->{list_obj} = 1;
    }
    if ($key =~ /^[Ii]$/) {
        if (!$inv->{on}) {
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
    my $coord = shift;
    my $map_obj = shift;
    my $move = shift;

    my $x = $coord->[$X];
    my $y = $coord->[$Y];

    my $map = $map_obj->{map};

    if ($move eq 'right') {
        if ($x + 1 < @{$map->[$coord->[$Y]]}) {
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
        return $coord;
    }

    $coord->[$X] = $x;
    $coord->[$Y] = $y;

    return $coord;
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

    _change_coord($coord, $map, $move);

}
