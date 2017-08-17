package parselog;

use strict;
use Exporter;
use File::Spec::Functions 'catfile';
use POSIX qw(strftime);
use File::Basename;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(parselog selectlog);
%EXPORT_TAGS = ();

sub selectlog {
	my $mode = shift || "last";
	my $start = shift || strftime "%Y%d%m", localtime;;
	my $stop  = shift || strftime "%Y%d%m", localtime;
	my $dir_path =  "data";

	my @fileList;
	if (opendir(DIR, $dir_path)) {
		while (my $file = readdir(DIR)) {
			next if ($file =~ m/^\./);
			push @fileList, catfile($dir_path, $file);
		}
	}

	@fileList = sort @fileList;
	if ($mode eq "last") {
		return $fileList[-1] || ();
	}

	my @filter;
	foreach my $item (@fileList) {
		my $fd = basename($item, ",log");
		push @filter, $item if (($start >= $fd) && ($fd <= $stop));
	}
	return @filter;
}

sub parselog {
  my @fileList = @_;
  my %database;
  foreach my $file (@fileList) {
	  # Use a regular expression to ignore files beginning with a period
	  if (open(FILE, "<", $file)) {
		  while (<FILE>) {
			  chomp;
			  #2017-08-12 22:10:20.255399 $0;0;0;14100;2708;1127;2900;
			  # Search module address
			  if (/\$(\d+)(.*)/) {
				  my $set = $2;
				  my $addr = $1;
				  # Get date and time
				  if (/^(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}:\d{2})/) {
					  # Save in hash all line that refer to a single module
					  # in following format:
					  # Addres -> [
					  #		[ date, time, measures.. ]
					  #		[ date, time, measures.. ]
					  #		...
					  # ]
					  my @a = ($1, $2, split ";", $set);
					  if (!exists $database{$addr}) {
						  $database{$addr} = [];
					  }
					  push $database{$addr},  [@a];
				  }
			  }
		  }
		  close FILE;
	  } else {
		  print "Error on $file: $!\n";
	  }
  }
  return %database;
}

1;
