package t::Util;
use strictures 1;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use HTTP::Cookies;

my $jar = HTTP::Cookies->new;

############################################################################
# Setup environment for Delti::WheelShop testing environment.

sub setenv {
  $ENV{PLACK_ENV} = $ENV{DANCER_ENVIRONMENT} = 'testing';
  $ENV{DANCER_SESSION_REDIS_TEST_MOCK} = 1;
}

############################################################################
# Setup environment for Delti::WheelShop testing environment.

sub setconf {
  my ($set) = @_;
  $set->( environment => 'testing' );
  $set->( warnings    => 1 );
  $set->( traces      => 1 );
  $set->( logger      => 'null' );
  $set->( show_errors => 1 );
  $set->( session     => 'Redis' );
  $set->( engines     => { session => { Redis => { redis_test_mock => 1 } } } );
  return;
}

############################################################################

sub psgi_request_ok {
  my ( $app, $method, $uri, $expected_response ) = @_;
  my $client = sub {
    my ($cb) = @_;
    my $req = HTTP::Request->new( $method => "http://localhost$uri" );
    $jar->add_cookie_header($req);
    my $res = $cb->($req);
    $jar->extract_cookies($res);
    subtest "$method $uri" => sub {
      plan tests => $expected_response ? 2 : 1;
      ok( $res->is_success, "request successful for $method $uri" );
      like( $res->decoded_content, $expected_response, "expected response content for $method $uri" )
        if $expected_response;
    };
    return;
  };
  test_psgi( $app, $client );
  return;
}

############################################################################
1;
