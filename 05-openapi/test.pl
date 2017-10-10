#!perl
use Mojo::Base -strict;
use Test::More tests => 28;
use Test::Mojo;
use FindBin;
use Time::Piece;
use Mojo::IOLoop::Delay;

require "$FindBin::Bin/weather";

my $t = Test::Mojo->new;

my $dt;
my $ep;

$t->get_ok('/api/time/MST7MDT')
  ->status_is(200)
  ->json_has('/epoch')
  ->json_has('/datetime')
  ->tap(sub { my $t = shift;
              $dt = $t->tx->res->json('/datetime');
              $ep = $t->tx->res->json('/epoch') });

# Mojo::IOLoop::Delay->new->steps(sub { Mojo::IOLoop->timer(2, shift->begin) },
#                                 sub { say STDERR "time" })->wait;

my $tp_mst = eval { local $ENV{TZ} = 'MST7MDT';
                    Time::Piece->strptime($dt, '%Y-%m-%dT%H:%M:%S'); };

is $tp_mst->datetime, $dt, "matching date-time value";

$t->get_ok('/api/time/EST5EDT')
  ->status_is(200)
  ->json_has('/epoch')
  ->json_has('/datetime')
  ->tap(sub { my $t = shift;
              $dt = $t->tx->res->json('/datetime');
              $ep = $t->tx->res->json('/epoch') });

my $tp_est = eval { local $ENV{TZ} = 'EST5EDT';
                    Time::Piece->strptime($dt, '%Y-%m-%dT%H:%M:%S'); };

is $tp_est->hour - $tp_mst->hour, 2, "time zone difference";

$t->get_ok('/api/time/FOO2BAR')
  ->status_is(400)
  ->json_is('/errors/0/path' => '/tz');

$t->get_ok('/api/temperature/40/-111')
  ->status_is(200)
  ->json_has('/fahrenheit')
  ->json_has('/celsius')
  ->json_has('/kelvin');

$t->get_ok('/api/temperature/91/-111')
  ->status_is(400)
  ->json_has('/errors')
  ->json_is('/errors/0/path' => '/lat');

$t->get_ok('/api/temperature/40/-181')
  ->status_is(400)
  ->json_has('/errors')
  ->json_is('/errors/0/path' => '/lon');

$t->post_ok('/api/temperature/40/100')
  ->status_is(200);
