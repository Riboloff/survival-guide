package Console;

use strict;
use warnings;
use utf8;

use lib qw/lib/;

sub new {
    my $class = shift;

    my $self = {};

    bless($self, $class);

    return $self;
}

1;
