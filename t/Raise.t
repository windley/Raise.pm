#!/usr/bin/perl -w

use lib qw(..);
use strict;

use Test::More;
use Test::LongString;
use Test::Deep;

use Kinetic::Raise;


my $ev1 = Kinetic::Raise->new('echo',
			      'hello',
			      {'rids' => 'a16x66',
			       'host' => 'cs.kobj.net'}
			     );

like($ev1->mk_url(),
     qr#http://cs.kobj.net/blue/event/echo/hello/a16x66/\d+#,
     "Blue; No options"
    );


like($ev1->mk_url({"foo" => "bar"}),
     qr#http://cs.kobj.net/blue/event/echo/hello/a16x66/\d+\?foo=bar$#,
     "Blue; With options"
    );


my $ev2 = Kinetic::Raise->new('echo',
			      'hello',
			      {'eci' => 'd799ed90-a6c7-012f-7e5d-00163e64d091'}
			     );

like($ev2->mk_url(),
     qr#http://cs.kobj.net/sky/event/[\da-f-]+/\d+\?_domain=echo&_type=hello$#,
     "Sky; No options"
    );


like($ev2->mk_url({"foo" => "bar"}),
     qr#http://cs.kobj.net/sky/event/[\da-f-]+/\d+\?foo=bar&fus_domain=echo&_type=hello$#,
     "Sky; No options"
    );



done_testing();
