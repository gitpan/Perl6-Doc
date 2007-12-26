use strict;
use warnings;
use lib 'lib', 'blib/lib';
use Test::More tests => 7;
use Test::Output;
use Perl6::Doc;

stdout_is(Perl6::Doc->new->process('-c'),        Perl6::Doc::contents());
stdout_is(Perl6::Doc->new->process('--contents'),Perl6::Doc::contents());
stdout_is(Perl6::Doc->new->process('-h'),        Perl6::Doc::help());
stdout_is(Perl6::Doc->new->process('--help'),    Perl6::Doc::help());
stdout_is(Perl6::Doc->new->process('-v'),        Perl6::Doc::version());
stdout_is(Perl6::Doc->new->process('--version'), Perl6::Doc::version());
stdout_is(Perl6::Doc->new->process('-bobo'),     Perl6::Doc::usage());




