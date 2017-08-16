package RadioLog::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller';
use parselog qw(parselog selectlog);

my @status_label = (
	"Id",
	"Data",
	"Ora",
	"LQI",
	"RSSI",
	"Up time",
);

# This action will render a template
sub home {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  my @filelist = selectlog();
  my %database = parselog(@filelist);

  # Fill data to render.
  my @dev_map = ();
  my @status_dev = ();
  foreach my $id (keys %database) {
	  my @l;
	  foreach ($database{$id}) {
		  push @l, $id;
		  foreach (@{$_}[-1]) {
			  foreach (@{$_}) {
				push @l, $_ if $_;
			  }
		  }
	  }
	  push @dev_map, [@l];
  }

  $self->stash(dev_map => \@dev_map);
  $self->stash(status_label => \@status_label);
  $self->stash(status_dev => \@status_dev);

  $self->render();
}

1;
