package Consts;

use strict;
use warnings;

use Term::ReadKey;
use Term::Cap;
use lib qw(lib);

use Exporter 'import';
our @EXPORT = qw($X $Y $LT $RD $size_term);

our $X = 1;
our $Y = 0;

#Размеры блоков интерфейса
our $LT = 0; #Left top
our $RD = 1; #reatht down

my ($wchar, $hchar) = GetTerminalSize();
$wchar--;
$hchar--;

our $size_term = [$hchar, $wchar];

1;
