# $Id: 1-basic.t 225 2008-02-12 23:49:44Z davidp $

# mock tests for Net::Shoutcast::Admin
# use Test::MockObject::Extends to fake communication with a Shoutcast server,
# returning the contents of example.xml, so we can test that the module
# handles it correctly and gives us the data we expect.

use strict;
use warnings;
use Test::More;
use FileHandle;
use lib '../lib';

eval "use Test::MockObject::Extends";
plan skip_all => "Test::MockObject::Extends required for mock testing" 
    if $@;

# OK, we have Test::MockObject::Extends, we're good to go
plan tests => 12;


use_ok( 'Net::Shoutcast::Admin' );

my $shoutcast = Net::Shoutcast::Admin->new(
    host => 'testhost',
    port => 1234,
    admin_password => 'testpass',
);

# This wraps the ua so that methods can be overridden for testing purposes
my $mocked_ua = 
    $shoutcast->{ua} = Test::MockObject::Extends->new( $shoutcast->{ua} );

$mocked_ua->mock("get", \&mock_get);
$mocked_ua->mock("is_success", sub { 1 });

sub mock_get {
    my ($self, $url) = @_;
    
    is($url, "http://testhost:1234/admin.cgi?pass=testpass&mode=viewxml",
        "URL for status XML is correct");
    
    # prepare a fake response object to return:
    my $res = Test::MockObject->new();
    $res->set_true( "is_success" );
    
    my $fh = new FileHandle 'example.xml';
    my $xml = join '', $fh->getlines;
    $fh->close;
    
    $res->set_always('content', $xml);
    return $res;
}


# right, now try a few requests;

my $song = $shoutcast->currentsong;
isa_ok($song, 'Net::Shoutcast::Admin::Song',
    '->currentsong returned an N::S::A::Song object');
    
is($song->title, 'Fake Song Title', 'Current song title is correct');



my $listeners_count = $shoutcast->listeners;
is($listeners_count, 2, '->listeners() returns 2 listeners in scalar context');


my @listeners = $shoutcast->listeners;
is(@listeners, 2, '->listeners returned 2 listeners in scalar context');
isa_ok($listeners[0], 'Net::Shoutcast::Admin::Listener',
    'first element of listeners list is a N::S::A::Listener object');
    
is($listeners[0]->host, '127.0.0.1', 'first listener has correct host');
is($listeners[0]->agent, 'testclient/1.2.3', 'first listener has correct agent');
is($listeners[0]->listen_time, 67, 'first listener has correct listen_time');


#diag("Total listeners: " . $shoutcast->listeners);

#diag("Current song: "    . $shoutcast->currentsong->title);

