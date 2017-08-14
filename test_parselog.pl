#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Scalar::Util qw(reftype);


use POSIX qw(strftime);
use parselog qw(parselog selectlog);

my $s = "20140221.log";
my $x = "20170806.log";
my $y = "20140220.log";
my @filelist = selectlog("range", $s, $y);
print "---", $s, "\n";
print join("\n", @filelist);
print "\n---", $y, "\n";

#my %database = parselog(@filelist);
#foreach (keys %database) {
#	foreach ($database{$_}) {
#		foreach (@{$_}) {
#			foreach (@{$_}) {
#			  print "tre ", $_, ref($_);
#			}
#			print "due ", $_, ref($_), "\n";
#		}
#		print "uno ", $_, ref($_), "\n";
#	}
#}
