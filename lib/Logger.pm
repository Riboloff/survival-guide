package Logger;

use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(dmp dmp_array);

use Data::Dumper;
my $tracefrom = 2;

sub dmp {
    my $fname = (caller(1 + $tracefrom - 1))[3];
    $fname = (caller(0 + $tracefrom - 1))[0] if !$fname;
    $fname //= '';

    my @d = ();
    for my $m1 (@_ ? @_ : $_) {
        my $msg = $m1;
        utf8::encode $msg if utf8::is_utf8($msg);
        push @d, $msg;
    }
    no warnings 'redefine';
    local *Data::Dumper::qquote = sub {
        my $s = shift;
        utf8::encode $s if utf8::is_utf8($s);
        return "'$s'";
    };

    open(my $INF, '>>', './debug.log');
    print $INF (join ', ', map {
        ref $_ ? Data::Dumper->new([$_])->Indent(1)->Pair(' => ')->Terse(1)->Sortkeys(1)->Useqq(1)->Useperl(1)->Dump()
          : defined($_) ? "'$_'"
          : 'undef'
    } @d),
        (
            ' ^^ dmp by ',
            "[$$] ",
            $fname,
            ':',
            (caller(1))[2]
        ),
      "\n";
	;

    close($INF);

    return 1;
}

sub dmp_array {
    my $data = shift;

    open(my $INF, '>>', './debug.log');
    for my $str (@$data) {
            print $INF join('', map {$_->{symbol}} @$str);
            print $INF "\n";
    }
    close($INF);

    return 1;
}

1;
