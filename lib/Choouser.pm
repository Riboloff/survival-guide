package Choouser;

use strict;
use warnings;

use lib qw(lib);
use Logger qw(dmp);
use Consts qw($X $Y $LT $RD);
use Interface;

sub new {
    my $self = shift;

    my $hash = {
        position => {
            action       => 0,
            list_obj     => 0,
            inv_bag      => 0,
            equipment    => 0,
            loot_list    => 0,
            looting_bag  => 0,
            craft_place  => 0,
            craft_bag    => 0,
            craft_result => 0,
        },
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
                    position => 0,
                    blocks => [
                        'looting_bag',
                        'loot_list',
                    ],
                },
            },
        },
    };

    return (bless $hash, $self);
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

    $self->{structure}{blocks}{$parent_block}{position} = $position;
    $self->{block_name} = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
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
    $self->{structure}{blocks}{$parent_block}{position} = $position;
    $self->{block_name} = $self->{structure}{blocks}{$parent_block}{blocks}[$position];
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
    for my $block_name (keys %{$self->{structure}{blocks}}) {
        $self->{structure}{blocks}{$block_name}{position} = 0;
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

    my $block_name = $self->{block_name};
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

1;
