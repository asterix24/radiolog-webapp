package RadioLog::Controller::Importer;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use JSON::Validator;


# This action will render a template
sub add {
  my $self = shift;
  my $validator = JSON::Validator->new;

  $validator->schema(
    {
      type       => "object",
      required   => ["address", "timestamp"],
      properties => {
        address      => { type => "integer"},
        label        => { type => "string" },
        description  => { type => "string" },
        address      => { type => "integer" },
        timestamp    => { type => "string", "format" => "date-time"},
        lqi          => { type => "integer" },
        rssi         => { type => "integer" },
        uptime       => { type => "integer" },
        tempcpu      => { type => "integer" },
        vrefcpu      => { type => "integer" },
        ntc0         => { type => "integer" },
        ntc1         => { type => "integer" },
        photores     => { type => "integer" },
        pressure     => { type => "integer" },
        temppressure => { type => "integer" }
      }
    }
  );


  my @errors = $validator->validate($self->req->json);
  my $id = "";
  my $status = Mojo::JSON->false;
  if (!@errors) {
    $id = $self->rldata->add($self->req->json);
    $status = Mojo::JSON->true;
  }
  $self->render(json => encode_json { id => $id, errors => [@errors], status => $status});
};

1
