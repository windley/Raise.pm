#!/usr/bin/perl -w
use strict;

use Getopt::Std;
use LWP::Simple;
use JSON::XS;

use Kinetic::Raise;

# must be an eci to a PEN with a16x66 or similar installed
my $eci = 'd799ed90-a6c7-012f-7e5d-00163e64d091';

# global options
use vars qw/ %opt /;
my $opt_string = 'h?e:m:';
getopts( "$opt_string", \%opt ); # or &usage();

my $event_type = $opt{'e'} || 'hello';
my $message = $opt{'m'} || '';

my $event = Kinetic::Raise->new('echo',
			       $event_type,
			       {'eci' => $eci}
			       );

my $response = $event->raise({'input' => $message});

foreach my $d (@{$response->{'directives'}}) {
  if ($d->{'name'} eq 'say') {
    print $d->{'options'}->{'something'}, "\n";
  }
}

