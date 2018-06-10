package Console;

use strict;
use warnings;
use utf8;

use Logger qw(dmp);

use lib qw/lib/;

sub new {
    my $class = shift;

    my $text = Language::read_json_file_lang('commands/connect');
    my $self = {
        ps1 => '[c=green,dark]gamer[/c]:[c=blue]~[/c]$ ',
        text => ['sudo rm -rf'],
        start_text => 'hello world',
        commands => {
            'connect' => {
                enable => 1,
                desc => $text->{desc},
                ping => $text->{ping},
                dir => '/bin'
            }
        },
        dirs => [
            '/bin',
            '/home',
        ],
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

sub get_commands_enable {
    my $self = shift;
    my $dir = shift || '';

    return [
        grep {$self->{commands}{$_}{dir} eq $dir}
        grep {$self->{commands}{$_}{enable}}
        keys %{$self->{commands}}
    ];
}

sub get_dirs {
    my $self = shift;

    return $self->{dirs};
}

sub get_command {
    my ($self, $command) = @_;

    return $self->{commands}{$command};
}

1;
