package Animation;

use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Consts;
use Logger qw(dmp);

sub new {
    my $class = shift;
    my $sub = shift;
    my $arg = shift;

    my $animation = {
        sub => $sub,
        arg => $arg,
    };

    bless($animation, $class);

    return $animation;
}

1;
