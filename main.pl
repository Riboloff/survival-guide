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
use Time;
use Init;

Init->new();
my $interface = Interface->new();
my $process_block = {};

$SIG{INT} = sub {ReadMode('normal'); exit(0)};

while(1) {
    $interface->print($process_block);
    $process_block = {};
    ReadMode('cbreak');
    while( defined (my $key_tmp = ReadKey(-1) )) {}; #Сброс буфера.
    my $key;
    while ( not defined ($key = ReadKey(-1) )) { #Во время простоя
        my $key_interrupt = $interface->print_animation();
        if ($key_interrupt) {
            $key = $key_interrupt;
            last;
        }
    };
    my @keys = ();
    push(@keys, ord $key);

    if (ord $key == 27) { #Обработка нажатие кнопки из некольких символов
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
