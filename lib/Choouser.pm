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
            action => 0,
            list_obj => 0,
        },
        block_name => 'list_obj',
        list => {},
    };

    return (bless $hash, $self);
}

sub down {
    my $self = shift;

    my $block_name = $self->{block_name};
    if ($self->{position}{$block_name} < $#{$self->{list}{$block_name}}) {
        $self->{position}{$block_name} ++;
    }
}

sub top {
    my $self = shift;
   
    my $block_name = $self->{block_name};
    if ($self->{position}{$block_name} > 0) {
        $self->{position}{$block_name}--;
    }
}

sub get_position {
    my $self = shift;

    my $block_name = $self->{block_name};
    return $self->{position}{$block_name};
}

sub reset_position {
    my $self = shift;

    $self->{position}{list_obj} = 0;
    $self->{position}{action} = 0;
    $self->{block_name} = 'list_obj';
}

sub add_list {
    my $self = shift;
    my $list = shift;
    my $block_name = shift || $self->{block_name};

    $self->{list}{$block_name} = $list;
}

1;
