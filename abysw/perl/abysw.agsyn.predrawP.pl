#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-07-10 14:48:50
    Example: abysw.agsyn.predrawP.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($help);
GetOptions(
  "help!"=>\&USAGE,)
or USAGE();

open IN, shift;
my %len;
my @genes;
while (<IN>){
	$len{$1} = $2 if /(\S+)\s+(\d+)/;
	push @genes, $1;
}

my $file = shift;
for my $i (1..$#genes){
	if ($file){
		open IN, $file;
	}else{
		open IN, "$genes[$i-1].$genes[$i].m8";
	}
	while (<IN>){
		my @line = split /\t/, $_;
		if ($line[0] eq $genes[$i-1] && $line[1] eq $genes[$i]){
			say join "\t", $genes[$i-1], $len{$genes[$i-1]}, @line[6..9], $line[2];
			say join "\t", $genes[$i], $len{$genes[$i]}, "0", "0", "0", "0", "0";
		}
	}
}
######################### Sub Routines #########################
sub USAGE{
my $uhead=`pod2text $0`;
my $usage=<<"USAGE";
USAGE:
	perl $0
	--help	output help information to screen
USAGE
print $uhead.$usage;
exit;}
