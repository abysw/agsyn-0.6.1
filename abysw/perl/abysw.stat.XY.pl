#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-10-07 11:11:24
    Example: abysw.stat.XY.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($help);
GetOptions(
  "help!"=>\&USAGE,)
or USAGE();

open IN, "sexchr";
while (<IN>){
	/(\S+)\s+(\S+)/;
	my $sp = $1;
	my $x = $2;
	my $lx = 0;
	my $ly = 0;
	my $gx = 0;
	my $gy = 0;
	open I, "faSize -detailed $sp.fa|";
	while (<I>){
		/(\S+)\s+(\S+)/;
		$lx = $2 if $x eq $1;
		$ly = $2 if $1 eq "Y";

	}
	open I, "$sp.gff";
	while (<I>){
		my $chr = $1 if /(\S+)\s+(\S+)/;
		if ($chr eq $x){
			$gx ++ if $_ =~ /\tgene\t/;
		}elsif($chr eq "Y"){
			$gy ++ if $_ =~ /\tgene\t/;
		}
	}
	say join "\t", $sp, $lx, $gx, $ly, $gy;
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
