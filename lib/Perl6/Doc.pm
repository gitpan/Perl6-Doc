package Perl6::Doc;
use 5.000;
use File::Spec;

$Perl6::Doc::VERSION = '0.33';

sub new {
    my $class = shift;
    bless({@_}, $class);
}

sub process {
    my $self = shift;
    my ($args, @values) = $self->get_opts(@_);
    $self->usage, return
      unless $self->validate_args($args);
    $self->help, return
      if $args->{-h} ||
         $args->{'--help'};
    $self->version, return
      if $args->{-v} ||
         $args->{'--version'};
    $self->contents, return
      if $args->{-c} ||
         $args->{'--contents'};
    $self->perldoc($args, @values);
}

sub get_opts {
    my $self = shift;
    my ($args, @values) = ({});
    for (@_) {
        $args->{$_}++, next if /^\-/;
        push @values, $_;
    }
    return ($args, @values);
}

sub validate_args {
    my $self = shift;
    my $args = shift;
    for (keys %$args) {
        return unless /^(
            -h | --help |
            -v | --version |
            -c | --contents |
            -t | -u | -m | -T
        )$/x;
    }
    return 1;
}

sub normalize_name {
    my $self = shift;
    my $id   = ucfirst(shift);
    $id =~ s/^(\d+)$/S$1/;
    $id =~ s/(\d+)/sprintf('%02s', $1)/e;
    return $id;
}

sub get_raw {
    my $self = shift;
    my $id = shift
      or die "Missing argument for get_raw";
    my $document = $self->normalize_name($id);
    $document .= '.pod';
    $document = File::Spec->catfile('Perl6', 'Doc', 'Bible', $document);
    my $document_path = '';
    for my $path (@INC) {
        my $file_path = File::Spec->catfile($path, $document);
        next unless -e $file_path;
        $document_path = $file_path;
        last;
    }
    die "No documentation for $id"
      unless $document_path;
    open DOC, $document_path;
    my $text = do {local $/, <DOC>};
    close DOC;
    return $text;
}

sub perldoc {
    my $self = shift;
    my $args = shift;
    my $document = __PACKAGE__ ;
    if (@_){
        my $file = $self->normalize_name( shift );
        my $sigil = substr $file, 0, 1;
        if ($file eq 'Perlintro'){
            $document .= '::Tutorial::perlintro';
        } elsif ($sigil eq 'T'){
            $document .= '::Tutorial::';
            if ($file eq 'T01') { $document .= 'perlintro' }
            else                { $self->contents, return  }
        } elsif ($file eq 'F01') { $document .= '::Doc::Capture';
        } elsif ($file eq 'F02') { $document .= '::Doc::FUD';
        } elsif ($sigil eq 'O') {
            $document .= '::Docs::';
            if    ($file eq 'O03') { $document .= 'Operator'  }
            elsif ($file eq 'O04') { $document .= 'Smartmatch'}
            elsif ($file eq 'O06') { $document .= 'Subroutine'}
            elsif ($file eq 'O08') { $document .= 'Variable'  }
            elsif ($file eq 'O09') { $document .= 'Data'      }
            elsif ($file eq 'O12') { $document .= 'Object'    }
            elsif ($file eq 'O16') { $document .= 'File'      } 
            else                   { $self->contents, return }
        } elsif ($sigil eq 'M') {
            $document .= '::Magazine::';
            if    ($file eq 'M01') { $document .= 'perl.com::EverydayPerl6'}
            elsif ($file eq 'M02') { $document .= 'perl.com::Perl6Parameter'}
            else                   { $self->contents, return }
        } else {
            $document .= '::Bible::' . $file_name;
        }
    }
    my $options = join ' ', grep { defined $args->{$_} } qw(-t -u -m -T);
    $options ||= '';
    my $command = "perldoc $options $document";
    $command .= " 2> /dev/null" unless $^O eq 'MSWin32';
    system $command;
}

sub usage {
    print <<_;

Usage: p6doc [options] [document-id]
Try `p6doc --help` for more information.
_
}

sub help {
    print <<_;

Usage: p6doc [options] [document-id]

Possible values for document-id are:
  A01 - A33  (Perl 6 Apocalypses)
  E01 - E33  (Perl 6 Exegeses)
  S01 - S33  (Perl 6 Synopses)
  O01 - O33  (Perl 6 Overview)
  F01 - F33  (Perl 6 FAQ)
  T01        (Perl 6 Tutorial)
  P00 - P09  (Perl(6)Tables)
  M01 - M11  (Mazine Articles)

Valid options:
  -h,  --help       Print this help screen
  -v,  --version    Print the publish date of this Perl6::Doc version
  -c,  --contents   Show the current table of contents

Additionally, the perldoc -t, -u, -m, or -T can be used to format the output.
_
}

sub version {
    print <<_;
This is Perl 6 Documentation as of December 24, 2007
(bundled in Perl6-Doc-$VERSION)
_
}

sub contents {
    my $module = __PACKAGE__;
    $module =~ s/::/\//g;
    $module .= '.pm';
    my $path = $INC{$module};
    open MOD, $path
      or die "Can't open $path for input";
    my $text = do {local $/; <MOD>};
    close MOD;
    $text =~ s/
        ^.*
        =head2 \s* (?=Contents)
    //sx or die "Can't find contents\n";
    $text =~ s/
        =head1 .*
    //sx or die "Can't find contents\n";
    $text =~ s/\A\s*\n//;
    $text =~ s/\s*\z/\n/;
    $text =~ s/^ {17}.*\n//mg;
    print $text;
}

__DATA__

=head1 NAME

Perl6::Doc - all useful Perl 6 Docs in your command line

=head1 VERSION

This document describes version 0.33 of Perl6::Doc, released
December 23, 2007.

=head1 SYNOPSIS

    > p6doc -h     # Show p6doc help
    > p6doc -c     # Show Table of Contents
    > p6doc s05    # Browse Synopsis 05
    > p6doc 5      # Same thing

=head1 DESCRIPTION

This Perl module distribution contains all the latest Perl 6
documentation and a utility called C<p6doc> for viewing it.

Below is the list of documents that are currently available; a number
in the column indicates the document is currently available. An 
asterisk next to a number means that the document is an unofficial
draft written by a member of the Perl community but not approved by
the Perl 6 Design Team.

=head2 Contents

    S01  The Ugly, the Bad, and the Good   (A01)
    S02  Bits and Pieces                   (A02) (E02)
    S03  Operators                         (A03) (E03)
    S04  Syntax                            (A04) (E04)
    S05  Pattern Matching                  (A05) (E05)
    S06  Subroutines                       (A06) (E06)
         Formats                                 (E07)
    S09  Data Structures
    S10  Packages
    S11  Modules
    S12  Objects                           (A12)
    S13  Overloading
    S16* IPC / IO / Signals  
    S17* Concurrency
         Debugging                         (A20*)
    S22* CPAN
         Portable Perl
    S26  Perl Documentation
    S27* Perl Culture
    S28* Special Names
    S29* Functions

    F01  FAQ::Captures
    F02  FAQ::FUD

    O03  Overview::Operator
    O04  Overview::Smartmatch
    O06  Overview::Subroutine
    O08  Overview::Variable
    O09  Overview::Data
    O12  Overview::Object
    O16  Overview::File
    
    T01  Tutorial perlintro

    M01  Everyday Perl 6
    M02  The Beauty of Perl 6 Parameter Passing

=head1 NOTES

L<Perl6::Doc> was before L<Perl6::Bible> which is now depreciated. We
changed that name, because we expect here much more content than just
Apocalypses, Exegeses and Synopses.

If you are interested in helping out the documentation project,
please contact us on C<irc.freenode.net #perl6> or
C<perl6-compiler@perl.org>.

=head2 Synopses

The document codes C<S01 - S33> refer to the Perl 6 Synopses.

The Synopsis documents are to be taken as the formal specification for
Perl 6 implementations, while still being reference documentation for
Perl 6, like _Programming Perl_ is for Perl 5.

Note that while these documents are considered "formal specifications",
they are still being subjected to the rigours of cross-examination
through implementation.

In other words, they may change slightly or radically. But the
expectation is that they are "very close" to the final shape of Perl 6.

=head2 Apocalypses (outdated)

The document codes C<A01 - A33> refer to the Perl 6 Apocalypses.

Larry Wall started the Apocalypse series as a systematic way of
answering the RFCs (Request For Comments) that started the design
process for Perl 6.  Each Apocalypse corresponds to a chapter in the
book _Programming Perl_, 3rd edition, and addresses the features
relating to that chapter in the book that are likely to change.

Larry addresses each relevant RFC, and gives reasons why he accepted
or rejected various pieces of it.  But each Apocalypse also goes
beyond a simple "yes" and "no" response to attack the roots of the
problems identified in the RFCs.

=head2 Exegeses (outdated)

The document codes C<E01 - E33> refer to the Perl 6 Exegeses.

Damian Conway's Exegeses are extensions of each Apocalypse.  Each
Exegesis is built around a practical code example that applies and
explains the new ideas.

=head2 Docs: Overview and FAQ

These are shorter summaries about a smaller specific topic. They are
written mostly by the crazy Pugs people and replacing some of the
outdated Synopses that are still marked as [Draft].

=head2 Tutorial (building up)

This is an community driven effort to translate the Perl 5 manpages
into the shiny Perl 6 world. There are still are half way through the
intro.

=head2 Perl Tables

Reference styled set of wiki pages made by myself.

=head2 Magazine articles

helpful articles from L<perl.com|http://www.perl.com> and L<$foo magazine|http://www.perl-magazin.de/> from various 
authors (see SCRIBES section). Taken with their permission :).

=head1 METHODS

Perl6::Doc provides a class method to get the raw text of a document:

    my $text = Perl6::Doc->get_raw('s01');

=head1 SCRIBES

* Ingy d�t Net <ingy@cpan.org>

* Sam Vilain <samv@cpan.org>

* Audrey Tang <autrijus@cpan.org>

* Herbert Breunung <lichtkind@cpan.org>

* Kirrily "Skud" Robert <skud@cpan.org>

* Moritz Lenz <moritz@fau2ik3.org>

* David Koenig <karhu@u.washington.edu>

* Jonathan Scott Duff <duff@pobox.com>

* Phil Crow <philcrow2000@yahoo.com>

=head1 SOURCES

A couple of paragraphs from _Perl 6 Essentials_ were used for the
overview. Most of the Bible docs (Apocalypses, Exegeses, Synopses)
are from the official Perl development site. 

http://dev.perl.org/perl6/

All draft Synopses, Overview, FAQ and Tutorial pages were taken out 
of the Pugs SVN repository.

http://svn.pugscode.org/pugs/docs/Perl6/

=head1 PACKAGING

Collection of docs is currently done by: Herbert Breunung <lichtkind@cpan.org>

=head1 COPYRIGHT

This Copyright applies only to the C<Perl6::Doc> Perl software
distribution, not the documents bundled within.

Copyright (c) 2007. Ingy d�t Net, Herbert Breunung. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
