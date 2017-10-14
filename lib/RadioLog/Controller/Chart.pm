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

sub data {
  my $self = shift;
  $self->app->log->debug("Input data:");
  $self->app->log->debug($self->req->json->{module_addr});

  my @data_graph = ();
  my @label = ();
  foreach (@{$self->req->json->{param}}) {
    $self->app->log->debug("Get Param: ".$_);
    push @label, $_;
    my $data = $self->rldata->graphdata($self->req->json->{module_addr});
    if ($_ eq 'pressure') {
      @{$data} = map($_ / 1000.0, @{$data});
    }
    push (@data_graph, $data, [$_]);
  }

  $self->render(json => {
      data => [@data_graph],
      label => [@label],
      module_addr => $self->req->json->{module_addr}
    }
  );
}

1;

