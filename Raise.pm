package Kynetx::Raise;

use strict;
use warnings;

use LWP::Simple;
use JSON::XS;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub new {
  my $invocant = shift;
  my $event_domain = shift;
  my $event_type = shift;
  my $rids = shift;
  my $options = shift;
  my $class = ref($invocant) || $invocant;
  
  unless (ref $rids eq 'ARRAY') {
    $rids = [split(';',$rids)];
  }

  my $self = {'event_domain' => $event_domain,
	      'event_type' => $event_type,
	      'rids' => $rids,
	      'host' => $options->{'host'} || 'cs.kobj.net',
	      'version' => $options->{'version'} || 'blue',
	      'scheme' => $options->{'schema'} || 'http',
	     };
  bless($self, $class); # consecrate
  return $self;
}

sub mk_url {
  my $self = shift;
  my $options = shift;

  my $queries = [];
  foreach my $k (keys %{$options}) {
    push @{ $queries }, "$k=$options->{$k}";
  }

  return $self->{'scheme'} ."://" .
         join('/', @{[$self->{'host'},
		      $self->{'version'},
		      'event',
		      $self->{'event_domain'},
		      $self->{'event_type'},
		      join(';', @{$self->{'rids'}}),
		      time
		      ]}) .
	'?' . join('&', @{$queries});
}

sub raise {
  my $self = shift;
  my $options = shift;

  my $response = get($self->mk_url($options));

  # strip comments
  $response =~ s#//.*\n##g;

  $response = JSON::XS->new->decode($response);

  return $response;
}


1;
