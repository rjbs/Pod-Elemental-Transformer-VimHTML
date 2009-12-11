package Pod::Elemental::Transformer::VimHTML;
use Moose;
with 'Pod::Elemental::Transformer::SynHi';
# ABSTRACT: convert "=begin vim" regions to colorized XHTML with Vim

=head1 DESCRIPTION

This transformer looks for regions like this:

  =begin vim lisp

    (map (stuff (lisp-has-lots-of '(,parens right))))

  =end vim

...into syntax-highlighted HTML that I can't really usefully represent here.
It uses L<Text::VimColor>, so you can read more about the kind of HTML it will
produce, there.  The parameter after "=begin vim" is used as the filetype.

This form is also accepted:

  #!vim lisp
  (map (stuff (lisp-has-lots-of '(,parens right))))

In the above example, the shebang-like line will be stripped.  The filetype
parameter is I<mandatory>.

B<Achtung!>  Two leading spaces are stripped from each line of the content to
be highlighted.  This behavior may change and become more configurable in the
future.

=cut

use Text::VimColor;

sub build_html {
  my ($self, $arg) = @_;
  my $string = $arg->{content};
  my $syntax = $arg->{syntax};

  $string =~ s/^  //gms;

  my $vim = Text::VimColor->new(
    string   => $string,
    filetype => $syntax,
  );

  return $self->standard_code_block( $vim->html );
}

sub synhi_params_for_para {
  my ($self, $para) = @_;

  if (
    $para->isa('Pod::Elemental::Element::Pod5::Region')
    and    $para->format_name eq 'vim'
  ) {
    die "=begin :vim makes no sense\n" if $para->is_pod;

    return {
      syntax  => $para->content,
      content => $para->children->[0]->as_pod_string,
    };
  } elsif ($para->isa('Pod::Elemental::Element::Pod5::Verbatim')) {
    my $content = $para->content;
    return unless $content =~ s/\A\s*#!vim\s+(\S+)\n+//gsm;
    return {
      content => $content,
      syntax  => $1,
    }
  }

  return;
}

1;
