use strictures 1;
use Test::More tests => 1 + 6;
use Test::NoWarnings;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';

use Util;

BEGIN { Util::setenv }

use TestApp::Simple;

BEGIN { Util::setconf( \&TestApp::Simple::set ) }

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
