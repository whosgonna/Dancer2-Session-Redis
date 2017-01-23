use strictures 1;
use Test::More tests => 1 + 2;
use Test::NoWarnings;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';

use Util;

BEGIN {
  Util::setenv;
  Util::mock_redis;
}

use TestApp::Simple;

BEGIN { Util::setconf( \&TestApp::Simple::set ) }

############################################################################

my $app = TestApp::Simple->psgi_app;
ok( $app, 'Got App' );

############################################################################

Util::psgi_request_ok( $app, GET => q{/}, qr/^Hello World$/ );

############################################################################
