package Craft;

use strict;
use warnings;

use utf8;

use lib qw(lib);
use Consts;
use Logger qw(dmp);
use ReadFile;
use Storable qw(dclone);

sub new {
    my $self = shift;
    my $bag_real = shift;

    my $bag_virt = dclone($bag_real);
    my $craft = {
        'list_items' => [],
        'bag' => $bag_virt,
    };

    bless($craft, $self);

    return $craft;
}

sub get_list_items {
    my $self = shift;

    return $self->{list_items};
}

sub get_bag {
    my $self = shift;

    return $self->{bag};
}

sub add_items {
    my $self = shift;
    my $positin_item = shift;

    my ($item) = splice(@{$self->{inv}}, $positin_item, 1);
    push(@{$self->{list_items}}, $item);
}

sub clean_items {
    my $self = shift;

    $self->{list_items} = [];
}

1;
