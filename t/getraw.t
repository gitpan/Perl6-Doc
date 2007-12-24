use strict;
use lib 'lib', 'blib/lib';
use Test::More tests => 1;
use Perl6::Doc;

open S, 'lib/Perl6/Doc/S01.pod';
my $text = do { local $/; <S> };

is(Perl6::Doc->get_raw('s01'), $text);
