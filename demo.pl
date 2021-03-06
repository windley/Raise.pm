#!/usr/bin/perl -w
use strict;

use Getopt::Std;
use LWP::Simple;
use JSON::XS;

use Kinetic::Raise;

# global options
use vars qw/ %opt /;
my $opt_string = 'h?e:m:';
getopts( "$opt_string", \%opt ); # or &usage();

my $event_type = $opt{'e'} || 'hello';
my $message = $opt{'m'} || '';

my $event = Kinetic::Raise->new('echo',
			       $event_type,
			       {'rids' => 'a16x66',
				'host' => 'cs.kobj.net'}
			       );

my $response = $event->raise({'input' => $message});

foreach my $d (@{$response->{'directives'}}) {
  if ($d->{'name'} eq 'say') {
    print $d->{'options'}->{'something'}, "\n";
  }
}

