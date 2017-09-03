package Choouser;

use strict;
use warnings;

use lib qw(lib);
use Logger qw(dmp);
use Consts qw($X $Y $LT $RD);

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
    };

    return (bless $hash, $self);
}

sub down {
    my $self = shift;

    my $block_name = $self->{block_name};
    if ($self->{position}{$block_name} < $#{$self->{list}{$block_name}}) {
        $self->{position}{$block_name}++;
    }
}

sub top {
    my $self = shift;
   
    my $block_name = $self->{block_name};
    if ($self->{position}{$block_name} > 0) {
        $self->{position}{$block_name}--;
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

    return $self->{bag}{$block_name};
}

sub set_position {
    my $self = shift;
    my $block_name = shift;
    my $position = shift;

    $self->{position}{$block_name} = $position;
}

sub reset_position {
    my $self = shift;

    for my $block_name (keys %{$self->{position}}) {
        $self->{position}{$block_name} = 0;
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
