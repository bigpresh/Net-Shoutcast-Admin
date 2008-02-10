use Test::More tests => 1;

BEGIN {
use_ok( 'Net::Shoutcast::Admin' );
}

my $shoutcast = Net::Shoutcast::Admin->new(
    host => 'dfr.preshweb.co.uk',
    port => 8000,
    admin_password => 'stella',
    agent => 'Mozilla',
);


my @listeners = $shoutcast->listeners;

for my $listener (@listeners) {
    diag( sprintf "%s is using %s and has been on for %s",
        $listener->host, $listener->agent, $listener->listen_time
    );
}
