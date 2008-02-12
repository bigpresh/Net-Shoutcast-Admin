# $Id$
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::Shoutcast::Admin',
    license             => 'perl',
    dist_author         => 'David Precious <davidp@preshweb.co.uk>',
    dist_version_from   => 'lib/Net/Shoutcast/Admin.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Net-Shoutcast-Admin-*' ],
);

$builder->create_build_script();
