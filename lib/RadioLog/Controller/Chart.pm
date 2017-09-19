package RadioLog::Controller::Chart;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub chart_home {
  my $self = shift;

  $self->stash(title => "Charts");
  $self->stash(subtitle => "Measure chart.");

  my @ids = $self->rldata->address();
  my $row = $self->rldata->last(@ids);

  $self->render(id => [@ids], rowdata => $row);
}

sub chartid {
  my $self = shift;

  $self->stash(title => "Charts ID");
  #$self->stash(subtitle => "Measure chart of id.");
  $self->stash(subtitle => $self->param('address'));

  $self->redirect_to('chart');
}

sub chart {
  my $self = shift;

  $self->stash(title => "Charts ID");
  $self->stash(subtitle => "Measure chart of id.");

  $self->render('chart');
}

1;

