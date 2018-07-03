package Wall;

use strict;
use warnings;
use utf8;
use Logger qw(dmp);
use Consts;

sub new {
    my ($class, $icon) = @_;

    my $obj_text = Language::get_text(OB_WALL, 'objects');
    my $wall = {
        name => $obj_text->{name},
        look => $obj_text->{look},
        icon => $icon,
    };

    bless($wall, $class);

    return $wall;
}

sub get_look {
    my $self = shift;

    return $self->{look};
}

sub get_icon {
    my $self = shift;

    return $self->{icon};
}

sub get_name {
    my $self = shift;

    return $self->{name};
}

1;
