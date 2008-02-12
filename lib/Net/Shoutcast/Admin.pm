package Net::Shoutcast::Admin;
# $Id$

use warnings;
use strict;
use Carp;
use Net::Shoutcast::Admin::Song;
use Net::Shoutcast::Admin::Listener;
use URI::Escape;
use LWP::UserAgent;
use XML::Simple;
use version; our $VERSION = qv('0.0.1');


=head1 NAME

Net::Shoutcast::Admin - administration of Shoutcast servers


=head1 VERSION

This document describes Net::Shoutcast::Admin version 0.0.1


=head1 SYNOPSIS

    use Net::Shoutcast::Admin;

    my $shoutcast = Net::Shoutcast::Admin->new(
                                    host => 'server hostname',
                                    port => 8000,
                                    admin_password => 'mypassword',
    );
    
    if ($shoutcast->source_connected) {
        printf "%s is currently playing %s by %s",
            $shoutcast->dj_name,
            $shoutcast->currentsong->title,
            $shoutcast->currentsong->artist
        ;
    } else {
        print "No source is currently connected.";
    }
  
  
=head1 DESCRIPTION

A module to interact with Shoutcast servers to retrieve information about
their current status (and perhaps in later versions of the module, to also
control the server in various ways).


=head1 INTERFACE 

=over 4

=item new

$shoutcast = Net::Shoutcast::Admin->new( %params );

Creates a new Net::Shoutcast::Admin object.  Takes a hash of options
as follows:

=over 4

=item B<host>

The hostname of the Shoutcast server you wish to query.

=item port

The port on which Shoutcast is running.  Defaults to 8000 if not specified.

=item B<admin_password>

The admin password for the Shoutcast server.

=item timeout

The number of seconds to wait for a response.  Defaults to 10 seconds if
not specified.

=item agent

The HTTP User-Agent header which will be sent in HTTP requests to the Shoutcast
server.  If not supplied, a suitable default will be used.

=back

=cut

sub new {

    my ($class, %params) = @_;
    
    my $self = bless {}, $class;
        
    $self->{last_update} = 0;
    
    my %acceptable_params = map { $_ => 1 } 
        qw(host port admin_password timeout agent);
    
    # make sure we haven't been given any bogus parameters:
    if (my @bad_params = grep { ! $acceptable_params{$_} } keys %params) {
        carp "Net::Shoutcast::Admin does not recognise param(s) "
            . join ',', @bad_params;
        return;
    }
    
    # 
    $self->{$_} = $params{$_} for keys %acceptable_params;
    
    # set decent defaults for optional params:
    $self->{port}    ||= 8000;
    $self->{agent}   ||= "Perl/Net::Shoutcast::Admin ($VERSION)";
    $self->{timeout} ||= 10;
    
    if (my @missing_params = grep { ! $self->{$_} } keys %acceptable_params) {
        carp "Net::Shoutcast::Admin->new() must be supplied with params: "
            . join ',', @missing_params;
        return;
    }
    
    # okay, fetch the data:
    $self->_fetch_status_xml;
    
    return $self;

}



sub _fetch_status_xml {
    my $self = shift;
    
    if ($self->{last_update} and (time - $self->{last_update}) < 5) {
        # status was updated not long ago
        return;
    }
        
    my ($host, $port) = @$self{qw(host port)};
    my $pass = URI::Escape::uri_escape( $self->{admin_password} );
    
    # TODO: URL-encode password
    my $url = "http://$host:$port/admin.cgi?pass=$pass&mode=viewxml";
    
    my $ua = new LWP::UserAgent;
    $ua->agent(   $self->{agent}   );
    $ua->timeout( $self->{timeout} );
    
    my $response = $ua->get($url);
    
    if (!$response->is_success) {
        carp "Failed to fetch status XML - " . $response->status_line;
        return;
    }
    
    my $data = XML::Simple::XMLin($response->content);
    $self->{data} = $data;
    $self->{last_update} = time;
}



=item currentsong

Returns a Net::Shoutcast::Admin::Song object representing the current
song.

=cut

sub currentsong {
    my $self = shift;
    
    my $song = Net::Shoutcast::Admin::Song->new( 
        title => $self->{data}->{SONGTITLE}
    );   
    return $song;
}


=item song_history

Returns a list of Net::Shoutcast::Admin::Song objects representing
the the last few songs played

=cut

sub song_history {
    my $self = shift;
    my @song_objects;
    
    for my $song (@{ $self->{data}->{SONGHISTORY}->{SONG} }) {
        push @song_objects, Net::Shoutcast::Admin::Song->new(
            title => $song->{TITLE},
            played_at => $song->{PLAYEDAT},
        );
    }
    
    return (@song_objects);
}


=item listeners

In scalar context, returns the number of listeners currently connected.
In list context, returns a list of Net::Shoutcast::Admin::Listener
objects representing each listener.

=cut

sub listeners {
    my $self = shift;
    
    if (!wantarray) {
        # okay, it's nice and simple:
        return $self->{data}->{CURRENTLISTENERS};
    } else {
        # okay, we need to return a list of N:S:A::Listener objects:
        my @listener_objects;
        for my $listener (@{ $self->{data}->{LISTENERS}->{LISTENER} }) {
            push @listener_objects, Net::Shoutcast::Admin::Listener->new(
                host         => $listener->{HOSTNAME},
                connect_time => $listener->{CONNECTTIME},
                underruns    => $listener->{UNDERRUNS} || 5,
                agent        => $listener->{USERAGENT},
            );
        }
            
        return (@listener_objects);
    }
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
