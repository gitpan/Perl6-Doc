use inc::Module::Install;

name            'Perl6-Doc';
all_from        'lib/Perl6/Doc.pm';
install_script  'p6doc';

WriteAll;
