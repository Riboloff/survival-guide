package Choouser;

use strict;
use warnings;

use lib qw(lib);
use Logger qw(dmp);
use Consts;
use Interface;

sub new {
    my $class = shift;

    my $hash = {
        position => {},
        block_name => 'list_obj',
        list => {},
        bag  => {},
        structure => {
            blocks => {
                objects => {
                    position => 0,
                    blocks =>[
                        'list_obj',
                        'action',
                    ]
                },
                inv => {
                    position => 0,
                    blocks => [
                        'inv_bag',
                        'equipment',
                    ],
                },
                craft => {
                    position => 0,
                    blocks => [
                        'craft_bag',
                        'craft_place',
                        'craft_result',
                    ],
                },
                looting => {
                    position => 1,
                    blocks => [
                        'looting_bag',
                        'loot_list',
                    ],
                },
                char => {
                    position => 0,
                    blocks => [
                        'char_dis',
                    ],
                },
                commands => {
                    position => 0,
                    blocks =>[
                        'dir',
                        'file',
                    ]
                },
            },
        },
    };

    my $self = (bless $hash, $class);
    return $self->init();
}

sub init {
    my $self = shift;

    my $blocks = $self->{structure}{blocks};
    for my $block (keys %$blocks) {
        my $position = $blocks->{$block}{position};
        for my $sub_blocks (@{$blocks->{$block}{blocks}}) {
            $self->{position}{$sub_blocks} = $position;
        }
    }

    return $self;
}

sub down {
    my $self = shift;

    my $block_name = $self->{block_name};
    $self->{position}{$block_name}++;
    my $number_last_element = $#{$self->{list}{$block_name}};
    if ($self->{position}{$block_name} > $number_last_element) {
        $self->{position}{$block_name} = 0;
    }
}

sub top {
    my $self = shift;

    my $block_name = $self->{block_name};
    $self->{position}{$block_name}--;
    my $number_last_element = $#{$self->{list}{$block_name}};
    if ($self->{position}{$block_name} < 0) {
        $self->{position}{$block_name} = $number_last_element;
    }
}

sub left {
    my $self = shift;

    my $parent_block = Interface::get_parent_block_name($self->{block_name});
    my $position = $self->{structure}{blocks}{$parent_block}{position};
    $position-- ;
    if ($position < 0) {
        my $number_last_element = $#{ $self->{structure}{blocks}{$parent_block}{blocks} };
        $position = $number_last_element;
    }

    my $next_block = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
    if (
        $self->{list}{$next_block}
        and @{$self->{list}{$next_block}}
    ) {
        $self->{structure}{blocks}{$parent_block}{position} = $position;
        $self->{block_name} = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
    }
}

sub right {
    my $self = shift;

    my $parent_block = Interface::get_parent_block_name($self->{block_name});
    my $position = $self->{structure}{blocks}{$parent_block}{position};


    $position++ ;
    my $number_last_element = $#{ $self->{structure}{blocks}{$parent_block}{blocks} };
    if ($position > $number_last_element) {
        $position = 0;
    }

    my $next_block = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
    if (
        $self->{list}{$next_block}
        and @{$self->{list}{$next_block}}
    ) {
        $self->{structure}{blocks}{$parent_block}{position} = $position;
        $self->{block_name} = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
    }
}

sub get_block_name {
    my $self = shift;

    return $self->{block_name};
}

sub get_position {
    my $self = shift;
    my $block_name = shift || $self->{block_name};

    return $self->{position}{$block_name};
}

sub get_bag {
    my $self = shift;
    my $block_name = shift || $self->{block_name};

    if ($block_name eq 'equipment') {
        my $position = $self->{position}{$block_name};
        my $item = $self->get_target_object->{item};
        my $slot = $item->get_slot();
        return $self->{bag}{$block_name}{slot}{$slot}{bag};
    }
    return $self->{bag}{$block_name};
}

sub set_position {
    my $self = shift;
    my $block_name = shift;
    my $position = shift;

    $self->{position}{$block_name} = $position;
}

sub reset_all_position {
    my $self = shift;

    for my $block_name (keys %{$self->{position}}) {
        $self->{position}{$block_name} = 0;
    }
    #TODO переписать. Брать из конфига структуру, такующе, как и при инициализации
    for my $block_name (keys %{$self->{structure}{blocks}}) {
        $self->{structure}{blocks}{$block_name}{position} = 0;
        if ($block_name eq 'looting') {
            $self->{structure}{blocks}{$block_name}{position} = 1;
        }
    }
    $self->{block_name} = 'list_obj';
}

sub add_list {
    my $self = shift;
    my $list = shift;
    my $block_name = shift || $self->{block_name};

    $self->{list}{$block_name} = $list;
}

sub get_target_object {
    my $self = shift;
    my $block_name = shift || $self->{block_name};

    my $position = $self->{position}{$block_name};
    my $obj = $self->{list}{$block_name}->[$position];

    return  $obj;
}

sub get_target_list {
    my $self = shift;

    my $block_name = $self->{block_name};
    my $list = $self->{list}{$block_name};

    return  $list;
}

sub move {
    my $self   = shift;
    my $buttom = shift;

    if ($buttom == KEYBOARD_UP) {
        $self->top();
    }
    elsif ($buttom == KEYBOARD_DOWN) {
        $self->down();
    }
    elsif ($buttom == KEYBOARD_LEFT) {
        $self->left();
    }
    elsif ($buttom == KEYBOARD_RIGHT) {
        $self->right();
    }

    return;
}

1;
