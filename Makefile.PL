use inc::Module::Install;

name            'Perl6-Doc';
all_from        'lib/Perl6/Doc.pm';
#build_requires  'Test::More';
#build_requires  'Test::Output';
install_script  'p6doc';

WriteAll;
