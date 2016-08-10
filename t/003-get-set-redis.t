use strictures 1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use t::Util;

BEGIN {
    plan( skip_all => "Author tests not required for installation" )
        unless $ENV{RELEASE_TESTING};
    t::Util::setenv;
    $ENV{DANCER_SESSION_REDIS_TEST_MOCK} = 0;
}

use t::TestApp::Simple;

BEGIN { t::Util::setconf( \&t::TestApp::Simple::set ) }

############################################################################

my $app = t::TestApp::Simple->psgi_app;
ok( $app, 'Got App' );

############################################################################

t::Util::psgi_request_ok( $app, GET => q{/get?key=foo},           qr/^get foo: $/ );
t::Util::psgi_request_ok( $app, GET => q{/set?key=foo&value=bar}, qr/^set foo: bar$/ );
t::Util::psgi_request_ok( $app, GET => q{/get?key=foo},           qr/^get foo: bar$/ );

############################################################################
done_testing;
