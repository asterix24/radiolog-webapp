package RadioLog;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;
use RadioLog::Model::RadioLogData;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(
    rldata => sub { state $data = RadioLog::Model::RadioLogData->new(pg => shift->pg) });

  # Migrate to latest version if necessary
  my $path = $self->home->child('migrations', 'radiologdata.sql');
  $self->log->info($path);
  $self->pg->migrations->name('radiologdata')->from_file($path)->migrate();


  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('dashboard#home');
  $r->get('/pg')->to('example#welcome');
}

1;
