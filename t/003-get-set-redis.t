use strictures 1;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';

use Util;

BEGIN {
    eval 'use Sereal::Decoder;1'
        or plan skip_all => "Sereal::Decoder needed to run these tests";
    eval 'use Sereal::Encoder;1'
        or plan skip_all => "Sereal::Encoder needed to run these tests";
    Util::setenv;
}

use TestApp::Simple;

BEGIN {
  Util::setconf( \&TestApp::Simple::set )
    or plan( skip_all => "Redis server not found so tests cannot be run" );
}

############################################################################

my $app = TestApp::Simple->psgi_app;
ok( $app, 'Got App' );

############################################################################

Util::psgi_request_ok( $app, GET => q{/get?key=foo},           qr/^get foo: $/ );
Util::psgi_request_ok( $app, GET => q{/set?key=foo&value=bar}, qr/^set foo: bar$/ );
Util::psgi_request_ok( $app, GET => q{/get?key=foo},           qr/^get foo: bar$/ );
Util::psgi_change_session_id( $app );
Util::psgi_request_ok( $app, GET => q{/get?key=foo},           qr/^get foo: bar$/ );

############################################################################
done_testing;
