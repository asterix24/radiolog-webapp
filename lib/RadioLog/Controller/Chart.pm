package RadioLog::Controller::Chart;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);

# This action will render a template
sub home {
  my $self = shift;

  $self->stash(title => "Charts");
  $self->stash(subtitle => "Measure chart.");
  $self->stash(data_url => $self->url_for('datachart')->to_abs);


  my @ids = $self->rldata->address();
  my $row = $self->rldata->last(@ids);

  $self->render(id => [@ids], rowdata => $row);
}

sub show {
  my $self = shift;
  my $id = $self->req->param('addr');
  $self->stash(title => "Charts ID");
  $self->stash(subtitle => "Moduel Address ".$id);

  my $row = $self->rldata->find($id);
  $self->render();
}

sub data {
  my $self = shift;
  $self->app->log->debug("Input data:");
  $self->app->log->debug($self->req->json->{module_addr});
  my @data_graph = ();
  foreach (@{$self->req->json->{param}}) {
    $self->app->log->debug("Get Param: ".$_);
    push @data_graph, $self->rldata->graphdata($self->req->json->{module_addr}, [$_]);
  }

  $self->render(json => {
        data => [@data_graph],
        module_addr => $self->req->json->{module_addr}
      }
    );
}

1;

