use Mojolicious::Lite;
use Mojo::Log;

use POSIX qw(strftime);
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use parselog qw(parselog);

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

	$log->info("Prova\n");

	# Get the last log file
	my @log_file_list = ();
	my $dir =  "data";
	if (opendir(DIR, $dir)) {
		while (my $file = readdir(DIR)) {
			# Use a regular expression to ignore files beginning with a period
			next if ($file =~ m/^\./);

			push @log_file_list, $dir."/".$file;
		}
		closedir(DIR);
		@log_file_list = sort @log_file_list;
	}

	my %d = ();
	if (@log_file_list) {
		my $n = $log_file_list[$#log_file_list];
		print "current log file: $n\n";
		# Find lastest devices update.
		if (open(FILE, "<", $n)) {
			while (<FILE>) {
				my ($id, $val);
                $id = -1;
                $val = -1;
				# Save device id and all log data of it
				if (/\$(\d+);/) {
					$id = $1;
					$val = $_;
                }
				#Check if current id is valid, and we have valid label map
				if (($id >= 0) && ($id < $#dev_map_available)) {
					$d{$id} = $val;
				} else {
					print "Error id=$id not valid, discard it! (max $#dev_map_available)\n";
					last;
				}
			}
			close FILE;
		} else {
			print "Error on $n: $!\n";
		}
	}

	# Fill data to render.
	my @dev_map = ();
	my @status_dev = ();
	foreach (sort keys %d) {
		my $line = $d{$_};
		$line =~ s/^\s+|\s+$//g;
		my @row = split '\$', $line;
		my @data = split ';', $row[1];
		my $dev_id = $data[0];
		my $ref = $dev_map_available[$dev_id];
		push @dev_map, $ref;
		my @d = ();
		for my $i (0..$#data) {
			#Break if we not have more label
			last if $i > $#{$ref};
			$ref->[$i]{'value'} = $data[$i];
			push @d, $data[$i] if $i <= $#status_label;
		}
		push @status_dev, [ @d ];
	}
	$self->stash(dev_map => \@dev_map);
	$self->stash(status_label => \@status_label);
	$self->stash(status_dev => \@status_dev);

} => 'home';

get '/uno' => 'graph';

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
	my %database = parselog();
	$self->stash(raw_data_label => \@raw_data_label);
	$self->stash(raw_database => { %database });
} => 'rawdata';

get '/json' => sub {
	my $self = shift;
	my @l = ();
	for (my $i = 0; $i < 24; $i++) {
		push @l, [ $i, rand(10)];
	}
	$self->render(json => [[@l]]);
};

app->start;



