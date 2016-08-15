package t::TestApp::Simple;
use strictures 1;
# ABSTRACT: Test application for unit tests.
# COPYRIGHT

BEGIN {
  our $VERSION = '0.001';  # fixed version - NOT handled via DZP::OurPkgVersion.
}

use Dancer2;
use Plack::Builder;
use Dancer2::Plugin::Redis;

############################################################################

get q{/} => sub { 'Hello World' };

get q{/set} => sub {
  no warnings 'all';
  session param('key') => param('value');
  sprintf 'set %s: %s', param('key'), session param('key');
};

get q{/get} => sub {
  no warnings 'all';
  sprintf 'get %s: %s', param('key'), session param('key');
};

get '/change_session_id' => sub {
  if ( app->can('change_session_id') ) {
    app->change_session_id;
    return "supported";
  }
  else {
    return "unsupported";
  }
};

############################################################################
builder { psgi_app };
