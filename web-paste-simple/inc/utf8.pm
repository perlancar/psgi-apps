#line 1
package utf8;

$utf8::hint_bits = 0x00800000;

our $VERSION = '1.09';

sub import {
    $^H |= $utf8::hint_bits;
    $enc{caller()} = $_[1] if $_[1];
}

sub unimport {
    $^H &= ~$utf8::hint_bits;
}

sub AUTOLOAD {
    require "utf8_heavy.pl";
    goto &$AUTOLOAD if defined &$AUTOLOAD;
    require Carp;
    Carp::croak("Undefined subroutine $AUTOLOAD called");
}

1;
__END__

