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
        #text => ['sudo rm -rf'],
        text => [
            {command => 'sudo rm -rf', output => 'access denied'},
        ],
        text_bufer => [],
        start_text => 'hello World',
        commands => {
            'connect' => {
                enable => 1,
                run => $text->{run},
                desc => $text->{desc},
                ping => $text->{ping},
                dir => '/bin'
            }
        },
        dirs => [
            '/bin',
            '/home',
        ],
        coord_cur => [0, 0],
    };

    bless($self, $class);

    return $self;
}

sub get_text {
    my $self = shift;

    return $self->{text};
}

sub get_text_flat {
    my $self = shift;

    my @text = ($self->{start_text});
    for my $line (@{$self->{text}}) {
        push(@text, $self->{ps1} . $line->{command});
        if ($line->{output}) {
            push(@text, $line->{output});
        }
    }

    push(@text, $self->{ps1} . '_' );

    return join("\n", @text);
}

sub get_ps1 {
    my $self = shift;

    return $self->{ps1};
}

sub get_last_command {
    my $self = shift;

    return $self->{text_bufer}[-1];
}

sub add_command {
    my ($self, $text) = @_;

    push(@{$self->{text_bufer}}, $text);
}

sub add_command_from_bufer {
    my ($self, $text) = @_;

    my $buff_command = shift @{$self->{text_bufer}};
    if ($buff_command) {
        push(@{$self->{text}}, $buff_command);
    }
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
