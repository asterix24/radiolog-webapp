package parselog;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(parselog);

use strict;
use warnings;
use File::Spec::Functions 'catfile';

sub parselog {
  my $dir_path =  "data";
  my %database = ();
  if (opendir(DIR, $dir_path)) {
	  while (my $file = readdir(DIR)) {
		  # Use a regular expression to ignore files beginning with a period
		  next if ($file =~ m/^\./);
		  if (open(FILE, "<", catfile($dir_path, $file))) {
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
	  closedir(DIR);
  }
  return %database;
}

1;
