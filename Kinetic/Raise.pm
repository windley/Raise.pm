package Kinetic::Raise;

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
  my $options = shift;
  my $class = ref($invocant) || $invocant;
  
  if ($options->{'rids'}) {
    unless (ref $options->{'rids'} eq 'ARRAY') {
      $options->{'rids'} = [split(';',$options->{'rids'})];
    }
  }

  # if you define an ECI, then its SKY
  my $version = $options->{'eci'} ? 'sky' : 'blue';

  my $self = {'event_domain' => $event_domain,
	      'event_type' => $event_type,
	      'rids' => $options->{'rids'} || [],
	      'host' => $options->{'host'} || 'cs.kobj.net',
	      'eci' => $options->{'eci'}, 
	      'version' => $version,
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

  
  my $url = "";

  if ($self->{'version'} eq 'blue') {
    $url = $self->{'scheme'} ."://" .
         join('/', @{[$self->{'host'},
		      $self->{'version'},
		      'event',
		      $self->{'event_domain'},
		      $self->{'event_type'},
		      join(';', @{$self->{'rids'}}),
		      time
		      ]}) .
	'?' . join('&', @{$queries});
  } elsif ($self->{'version'} eq 'sky') {

    push(@{$queries}, "_domain=". $self->{'event_domain'});
    push(@{$queries}, "_type=". $self->{'event_type'});
    push(@{$queries}, "_rids=". join(';', @{$self->{'rids'}})) unless join(';', @{$self->{'rids'}}) eq '' ;
    $url = $self->{'scheme'} ."://" .
         join('/', @{[$self->{'host'},
		      $self->{'version'},
		      'event',
		      $self->{'eci'},
		      time
		      ]}) .
	'?' . join('&', @{$queries});
  } 

  return $url;
}

sub raise {
  my $self = shift;
  my $options = shift;

  my $response = get($self->mk_url($options)) || "";

  # strip comments
  $response =~ s#//.*\n##g;

  $response = JSON::XS->new->decode($response);

  return $response;
}


1;
