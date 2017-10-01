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
  my $result = $self->pg->db->query('select DISTINCT address from radiologdata order by address asc');
  my @ret;
  while (my $next = $result->hash) {
    push @ret, $next->{address};
  }
  return @ret;
}

sub graphdata {
  my $self = shift;
  my $address = shift;
  my $key = shift;

  my $result = $self->pg->db->query('select timestamp, '.$key.' from radiologdata where address='.$address.' order by timestamp asc');

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
