package Console;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);

use lib qw/lib/;

sub new {
    my $class = shift;

    my $self = {
        ps1 => '[c=green,dark]gamer[/c]:[c=blue]~[/c]$ ',
        text => ['sudo rm -rf'],
        start_text => 'hello world',
    };

    bless($self, $class);

    return $self;
}

sub get_text {
    my $self = shift;

    my @text = ($self->{start_text});
    for my $line (@{$self->{text}}) {
        push(@text, $self->{ps1} . $line);
    }
    push(@text, $self->{ps1} . '_' );

    return join("\n", @text);
}

sub add_command {
    my ($self, $string) = @_;

    push(@{$self->{text}}, $string);
}

1;
