package Net::Shoutcast::Song;

use warnings;
use strict;
use Carp;
use Lyrics::Fetcher;

use version; our $VERSION = qv('0.0.1');


=head1 NAME

Net::Shoutcast::Admin::Song - object to represent a song


=head1 SYNOPSIS

    use Net::Shoutcast::Admin;

    my $shoutcast = Net::Shoutcast::Admin->new(
                                    host => 'server hostname',
                                    port => 8000,
                                    admin_password => 'mypassword',
    );
    
    if ($shoutcast->source_connected) {
        my $current_song = $shoutcast->currentsong;
        
        printf "Current song is %s by %s",
            $shoutcast->currentsong->title,
            $shoutcast->currentsong->artist
        ;
    } else {
        print "No source is currently connected.";
    }
  
  
=head1 DESCRIPTION

Object representing a song, returned by Net::Shoutcast::Admin


=head1 INTERFACE 

=over 4

=item new

There's no reason to create instances of Net::Shoutcast::Admin::Song directly;
Net::Shoutcast::Admin creates and returns instances for you.

Having said that:

  $song = Net::Shoutcast::Admin::Song->new( %params );

Creates a new Net::Shoutcast::Admin object.  Takes a hash of options
as follows:

=over 4

=item I<artist>

The artist of the song

=item I<title>

The title of the song

=back

=cut

sub new {

    my ($class, %params) = shift;
    
    my $self = bless {}, $class;
        
    $self->{last_update} = 0;
    
    my %acceptable_params = map { $_ => 1 } 
        qw(artist title);
    
    # make sure we haven't been given any bogus parameters:
    if (my @bad_params = grep { ! $acceptable_params{$_} } keys %params) {
        carp "Net::Shoutcast::Admin::Song does not recognise param(s) "
            . join ',', @bad_params;
        return;
    }
    
    $self->{$_} = $params{$_} for keys %acceptable_params;
    
    if (my @missing_params = grep { ! $self->{$_} } keys %acceptable_params) {
        carp "Net::Shoutcast::Admin->new() must be supplied with params: "
            . join ',', @missing_params;
        return;
    }
    
    return $self;

}


=item artist

Returns the artist

=cut

sub artist {
    return shift->{artist};
}

=item title

Returns the title of the song

=cut

sub title {
    return shift->{title};
}

=item lyrics

Attempt to fetch the lyrics for this song using Lyrics::Fetcher

=cut

sub lyrics {
    my $self = shift;
    return Lyrics::Fetcher->fetch($self->artist, $self->title);
}
    




1; # Magic true value required at end of module
__END__


=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-shoutcast-admin@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

David Precious  C<< <davidp@preshweb.co.uk> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, David Precious C<< <davidp@preshweb.co.uk> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
