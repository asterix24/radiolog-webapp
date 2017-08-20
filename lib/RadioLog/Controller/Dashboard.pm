package RadioLog::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller';
use parselog qw(parselog selectlog);

my @colors = (
  "is-primary",
  "is-warning",
  "is-info",
  "is-danger",
  "is-success"
);

# This action will render a template
sub home {
  my $self = shift;

  $self->stash(title => "Dashboard");
  $self->stash(subtitle => "Radiolog system on-line module");

  my @ids = $self->rldata->address();
  my $row = $self->rldata->last(@ids);


  $self->stash(color => [@colors]);
  $self->render(id => [@ids], rowdata => $row);
}

1;
