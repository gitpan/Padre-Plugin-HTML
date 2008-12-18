package Padre::Plugin::HTML;

use warnings;
use strict;

our $VERSION = '0.01';

use base 'Padre::Plugin';
use Wx ':everything';

sub padre_interfaces {
	'Padre::Plugin' => '0.21',
}

sub menu_plugins_simple {
	'HTML' => [
		'Validate HTML',  \&validate_html,
		'Tidy HTML', \&tidy_html,
	];
}

sub validate_html {
	my ( $self ) = @_;
	
	my $doc  = $self->selected_document;
	my $code = $doc->text_get;
	
	unless ( $code and length($code) ) {
		Wx::MessageBox( 'No Code', 'Error', Wx::wxOK | Wx::wxCENTRE, $self );
	}
	
	require WebService::Validator::HTML::W3C;
	my $v = WebService::Validator::HTML::W3C->new(
		detailed => 1
	);

	if ( $v->validate_markup($code) ) {
        if ( $v->is_valid ) {
			_output( $self, "HTML is valid\n" );
        } else {
			my $error_text = "HTML is not valid\n";
            foreach my $error ( @{$v->errors} ) {
                $error_text .= sprintf("%s at line %d\n", $error->msg, $error->line);
            }
            _output( $self, $error_text );
        }
    } else {
        my $error_text = sprintf("Failed to validate the code: %s\n", $v->validator_error);
        _output( $self, $error_text );
    }
}

sub _output {
	my ( $self, $text ) = @_;
	
	$self->show_output;
	$self->{gui}->{output_panel}->clear;
	$self->{gui}->{output_panel}->AppendText($text);
}

sub tidy_html {
	my ( $self ) = @_;
	
	my $src = $self->selected_text;
	my $doc = $self->selected_document;
	my $code = ( $src ) ? $src : $doc->text_get;
	
	return unless ( defined $code and length($code) );
	
	require HTML::Tidy;
	my $tidy = HTML::Tidy->new;

	{
		no warnings;
		$tidy->parse( $0, $code );
	}

	my $text;
    for my $message ( $tidy->messages ) {
        $text .= $message->as_string . "\n";
    }
    
    $text = 'OK' unless ( length($text) );
	$self->show_output;
	$self->{gui}->{output_panel}->clear;
	$self->{gui}->{output_panel}->AppendText($text);
}

1;
__END__

=head1 NAME

Padre::Plugin::HTML - L<Padre> and HTML

=head1 Validate HTML

use L<WebService::Validator::HTML::W3C> to validate the HTML

=head1 Tidy HTML

use L<HTML::Tidy> to tidy HTML

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut