#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Term::ReadKey;

use lib qw/lib/;

use Bot;
use Character;
use Choouser;
use Consts;
use Craft;
use Events;
use Inv;
use Interface;
use Logger qw(dmp);
use Map;
use Keyboard;
use Keyboard::Consts;
use Target;
use Text;
use Time;

use constant {
    FRIENDLY => 1,
    FOE => 0,
};

my $map = Map->new('squa');
my $start_coord = [10, 18];
my $character = Character->new($start_coord);

my $chooser = Choouser->new();
my $text_obj = Text->new(file => 'text_test');
my $inv = $character->get_inv();

my $bots = [
    Bot->new(OB_BOT_DOG, [11,20], '@', 'blue', FRIENDLY, $map),
    Bot->new(OB_BOT_ZOMBIE, [12,20], 'Z', 'red', FOE, $map),
];
my $current_time = Time->new( {'speed' => 1} );
my $interface = Interface->new(
    {
        map       => $map, 
        character => $character,
        text_obj  => $text_obj,
        chooser   => $chooser,
        inv       => $inv,
        bots      => $bots,
        target    => Target->new(),
        time      => Time->new( {'speed' => 1} ), 
    }
);
$text_obj->set_size_area_text($interface->{text});
my $process_block = {};

$SIG{INT} = sub {ReadMode('normal'); exit(0)};

while(1) {
    $interface->print($process_block);

    $process_block = {};
    ReadMode('cbreak');
    while( defined (my $key_tmp = ReadKey(-1) )) {};
    my $key = ReadKey(0);
    my @keys = ();
    push(@keys, ord $key);

    if (ord $key == 27) {
        while( defined (my $key_yet = ReadKey(-1) )) {
            push @keys, ord $key_yet;
        }
    }
    #dmp($key); dmp(ord $key);
    if (Interface::Size::is_change_term_size()) {
        $interface->set_size_all_block();
        $interface->{data_print} = Interface::_data_print_init($interface->{size}, $interface->{map}{size});
        $process_block->{all} = 1;
        next;
    }
    my $actions = Keyboard::get_actions(@keys);
    next unless($actions);
    for my $action (@{$actions}) {
        if (
            ref $action eq 'HASH'
            and ref $action->{sub} eq 'CODE'
        ) {
            my $blocks = $action->{sub}->($interface, $action->{args});
            map {$process_block->{$_} = $blocks->{$_}} keys %$blocks;
        }
    }
    #TODO Кажется не на своем месте вызов ф-и
    Events::check_timeout();
}
