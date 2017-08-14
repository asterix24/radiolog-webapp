#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Scalar::Util qw(reftype);


use POSIX qw(strftime);
use parselog qw(parselog selectlog);

#my $s = "20140221.log";
#my $x = "20170806.log";
#my $y = "20140220.log";
#my @filelist = selectlog("range", $s, $y);
#print "---", $s, "\n";
#print join("\n", @filelist);
#print "\n---", $y, "\n";

my @filelist = selectlog();
my %database = parselog(@filelist);

my @d;
foreach my $id (keys %database) {
	my @l;
	foreach ($database{$id}) {
		push @l, $id;
		foreach (@{$_}[-1]) {
			foreach (@{$_}) {
			  push @l, $_;
			}
		}
	}
	push @d, [@l];
}

print join(" - ", @d), "\n";
foreach (@d) {
  foreach (@$_) {
	print $_, " - ";
  }
  print "\n";
}
