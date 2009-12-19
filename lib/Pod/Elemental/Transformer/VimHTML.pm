package Pod::Elemental::Transformer::VimHTML;
use Moose;
# ABSTRACT: convert "=begin vim" regions to colorized XHTML with Vim

=head1 DESCRIPTION

This transformer looks for regions like this:

  =begin vim lisp

    (map (stuff (lisp-has-lots-of '(,parens right))))

  =end vim

...into syntax-highlighted HTML that I can't really usefully represent here.
It uses L<Text::VimColor>, so you can read more about the kind of HTML it will
produce, there.  The parameter after "=begin vim" is used as the filetype.

This form is also accepted, in a verbatim paragraph:

  #!vim lisp
  (map (stuff (lisp-has-lots-of '(,parens right))))

In the above example, the shebang-like line will be stripped.  The filetype
parameter is I<mandatory>.

B<Achtung!>  Two leading spaces are stripped from each line of the content to
be highlighted.  This behavior may change and become more configurable in the
future.

=cut

use Text::VimColor;

has format_name => (is => 'ro', isa => 'Str', default => 'vim');

sub build_html {
  my ($self, $arg) = @_;

  my $str = $arg->{content};
  my $opt = $arg->{options};

  $str =~ s/^  //gms;

  my $vim = Text::VimColor->new(
    string   => $str,
    filetype => $opt->{filetype},
  );

  return $self->standard_code_block( $vim->html );
}

sub parse_synhi_param {
  my ($self, $str) = @_;

  my @opts = split /\s+/, $str;

  confess "no filetype provided for VimHTML region" unless @opts;

  confess "illegal VimHTML region parameter: $str"
    unless @opts == 1 and $opts[0] !~ /:/;

  return { filetype => $opts[0] };
}

with 'Pod::Elemental::Transformer::SynHi';
1;
