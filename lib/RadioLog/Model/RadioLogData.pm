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

sub remove {
  my ($self, $id) = @_;
  $self->pg->db->delete('radiologdata', {id => $id});
}

sub save {
  my ($self, $id, $data) = @_;
  $self->pg->db->update('radiologdata', $data, {id => $id});
}

1;
