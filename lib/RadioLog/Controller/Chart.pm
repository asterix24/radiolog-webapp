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

  my @data_graph = ();
  my @label = ();

  foreach my $addr (@{$self->req->json->{module_addr}}) {
    foreach (@{$self->req->json->{param}}) {
      $self->app->log->debug("Get Param: ".$_);
      my $data = $self->rldata->graphdata($addr, [$_]);
      my $label = "";
      if (/pressure/) {
        @{$data} = map([$_->[0], $_->[1] / 1000.0], @{$data});
        $label = "Pressure [mbar]";
      } elsif (/ntc?|tempcpu/) {
        @{$data} = map([$_->[0], $_->[1] / 100.0], @{$data});
        $label = "$_ [C]";
      } elsif (/vrefcpu/) {
        @{$data} = map([$_->[0], $_->[1] / 1000.0], @{$data});
        $label = "Vref [V]";
      } elsif (/photores/) {
        @{$data} = map([$_->[0], $_->[1] / 100.0], @{$data});
        $label = "Photoresistence [LSB]";
      }

      push @label, $label;
      push @data_graph, $data;
    }
  }

  $self->render(json => {
      data => [@data_graph],
      label => [@label],
    }
  );
}

1;

