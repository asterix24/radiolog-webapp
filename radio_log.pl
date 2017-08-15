use Mojolicious::Lite;
use Mojo::Log;

use POSIX qw(strftime);
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use parselog qw(parselog selectlog);

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => './log/mojo.log', level => 'info');
	

my @status_label = (
	"Id",
	"Data",
	"Ora",
	"LQI",
	"RSSI",
	"Up time",
);

my @dev_module1_map = (
	{"label" => "Id"       , "value" => "-" },
	{"label" => "Data"     , "value" => "-" },
	{"label" => "Ora"      , "value" => "-" },
	{"label" => "LQI"      , "value" => "-" },
	{"label" => "RSSI"     , "value" => "-" },
	{"label" => "Up Time"  , "value" => "-" },
	{"label" => "Label"    , "value" => "-" },
	{"label" => "CPU Temp" , "value" => "-" },
	{"label" => "CPU Vint" , "value" => "-" },
	{"label" => "Temp1"    , "value" => "-" },
	{"label" => "Temp2"    , "value" => "-" },
	{"label" => "Light"    , "value" => "-" },
	{"label" => "Pressure" , "value" => "-" },
	{"label" => "Press Temp", "value" => "-" },
);

my @dev_default_map = (
	{"label" => "Id"       , "value" => "-" },
	{"label" => "Data"     , "value" => "-" },
	{"label" => "Ora"      , "value" => "-" },
	{"label" => "LQI"      , "value" => "-" },
	{"label" => "RSSI"     , "value" => "-" },
	{"label" => "Label"    , "value" => "-" },
	{"label" => "Up Time"  , "value" => "-" },
	{"label" => "CPU Temp" , "value" => "-" },
	{"label" => "CPU Vint" , "value" => "-" },
);

my @dev_master_map = (
	{"label" => "Id"       , "value" => "-" },
	{"label" => "Data"     , "value" => "-" },
	{"label" => "Ora"      , "value" => "-" },
	{"label" => "LQI"      , "value" => "-" },
	{"label" => "RSSI"     , "value" => "-" },
	{"label" => "Label"    , "value" => "-" },
	{"label" => "Up Time"  , "value" => "-" },
	{"label" => "CPU Temp" , "value" => "-" },
	{"label" => "CPU Vint" , "value" => "-" },
	{"label" => "Temp1"    , "value" => "-" },
);

my @dev_map_available = (
	\@dev_master_map,   #Master 0
	\@dev_default_map,  # Module 1
	\@dev_default_map,  # Module 2
	\@dev_default_map,  # Module 3
	\@dev_default_map,  # Module 4
	\@dev_default_map,  # Module 5
	\@dev_default_map,  # Module 6
	\@dev_default_map,  # Module 7
	\@dev_module1_map,  # Module 8
	\@dev_default_map,  # Module 9
	\@dev_module1_map,  # Module 10
	\@dev_default_map,  # Module 11
	\@dev_default_map,  # Module 12
	\@dev_default_map,  # Module 13
	\@dev_default_map,  # Module 14
	\@dev_default_map,  # Module 15
);

# Simple plain text response
get '/' => sub {
	my $self  = shift;
	#$self->stash(host => $self->req->url->to_abs->host);
	#$self->stash(ua => $self->req->headers->user_agent);
	#

	$log->info("Home\n");

	my @filelist = selectlog();
	my %database = parselog(@filelist);

	# Fill data to render.
	my @dev_map = ();
	my @status_dev = ();
	foreach my $id (keys %database) {
		my @l;
		foreach ($database{$id}) {
			push @l, $id;
			foreach (@{$_}[-1]) {
				foreach (@{$_}) {
				  push @l, $_ if $_;
				}
			}
		}
		push @dev_map, [@l];
	}

	$self->stash(dev_map => \@dev_map);
	$self->stash(status_label => \@status_label);
	$self->stash(status_dev => \@status_dev);

} => 'home';


my @raw_data_label = (
	"Id",
	"Data",
	"Ora",
	"LQI",
	"RSSI",
	"Uptime",
	"TempCPU",
	"VrefCPU",
	"NTC0",
	"NTC1",
	"PhotoRes",
	"Pressure",
	"TempPressure",
);

get '/raw' => sub {
	my $self  = shift;
	my @filelist = selectlog();
	my %database = parselog(@filelist);

	$self->stash(raw_data_label => \@raw_data_label);
	$self->stash(raw_database => { %database });
} => 'rawdata';

get '/graph' => 'graph';
get '/json' => sub {
	my $self = shift;

	my @filelist = selectlog();
	my %database = parselog(@filelist);
	my @l;
	foreach ($database{8}) {
		foreach (@{$_}) {
			push @l, [@$_[1], @$_[8]] if $_;
		}
	}
	my @m;
	foreach ($database{10}) {
		foreach (@{$_}) {
			push @m, [@$_[1], @$_[8]] if $_;
		}
	}

	my @n;
	foreach ($database{0}) {
		foreach (@{$_}) {
			push @n, [@$_[1], @$_[8]] if $_;
		}
	}

	$self->render(json => [[@l], [@m], [@n]]);
};

app->start;



