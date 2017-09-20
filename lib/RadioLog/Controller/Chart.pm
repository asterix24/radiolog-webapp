package RadioLog::Controller::Chart;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub home {
  my $self = shift;

  $self->stash(title => "Charts");
  $self->stash(subtitle => "Measure chart.");

  my @ids = $self->rldata->address();
  my $row = $self->rldata->last(@ids);

  $self->render(id => [@ids], rowdata => $row);
}

sub show {
  my $self = shift;
  my $id = $self->req->param('addr');
  $self->stash(title => "Charts ID");
  $self->stash(subtitle => "Moduel Address ".$id);

  print $id."\n";
  my $row = $self->rldata->find($id);
  foreach my $i (keys $row) {
    print $i."->".$row->{$i}."\n";
  }

  $self->render();
}

1;

