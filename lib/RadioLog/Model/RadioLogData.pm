package RadioLog::Model::RadioLogData;
use Mojo::Base -base;

has 'pg';

sub add {
  my ($self, $data) = @_;
  return $self->pg->db->insert('radiologdata', $data, {returning => 'id'})->hash->{id};
}

sub all { shift->pg->db->select('radiologdata')->hashes->to_array }

sub find {
  my ($self, $id) = @_;
  return $self->pg->db->select('radiologdata', undef, {id => $id})->hash;
}

sub address {
  my $self = shift;
  my $result = $self->pg->db->select('radiologdata', ['address'], undef, { -asc => 'address' });

  my %address;
  foreach my $idx (@{$result->hashes}) {
      $address{$idx->{address}} = 0;
  }
  return sort (keys %address);
}

sub graphdata {
  my $self = shift;
  my $address = shift;
  my $keys = shift;

  splice @{$keys}, 0, 0, 'timestamp';
  my $result = $self->pg->db->select('radiologdata', $keys, {address => $address}, {-asc => 'timestamp'});
  return $result->arrays;
}

sub last {
  my ($self, @addr) = @_;

  my @data;
  foreach my $id (@addr) {
    my $result = $self->pg->db->select('radiologdata', undef, {address => $id}, { -desc => 'timestamp' });
    push @data, $result->hash;
    $result->finish;
  }
  return [@data];
}

sub remove {
  my ($self, $id) = @_;
  $self->pg->db->delete('radiologdata', {id => $id});
}

sub save {
  my ($self, $id, $data) = @_;
  $self->pg->db->update('radiologdata', $data, {id => $id});
}

1;
