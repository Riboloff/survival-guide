package Interface::Commands;

use strict;
use warnings;
use utf8;

use Consts;
use Interface::Utils;
use Interface::Window;
use Logger qw(dmp);
use Storable qw(dclone);
use Text;

sub process_dir {
    my ($interface, $window) = @_;

    return $window->create_sub_block_list(
        dclone($interface->get_dir),
        'dir',
        $interface->get_chooser(),
        [1111, 222],
    );
}

sub process_file {
    my ($interface, $window) = @_;

    return $window->create_sub_block_list(
        dclone($interface->get_file),
        'file',
        $interface->get_chooser(),
        [33333, 44444],
    );
}

sub process_block {
    my $interface = shift;

    my $window = Interface::Window->new(
            size => {
                main => $interface->get_commands->{size},
                sub => {
                    dir  => $interface->get_dir->{size}, 
                    file => $interface->get_file->{size}, 
                }
            }
    );

    my $dir  = process_dir($interface, $window);
    my $file = process_file($interface, $window);

    $window->add_sub_block('dir',  $dir);
    $window->add_sub_block('file', $file);
    $interface->create_window($window);

    return;
}

1;
