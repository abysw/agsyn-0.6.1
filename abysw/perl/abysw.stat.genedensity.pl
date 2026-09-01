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
my $out = "genedensity";
mkdir $out;
open OUT, ">stat.XY.xls";
open OUT1, ">stat.GD.X.xls";
open OUT2, ">stat.GD.Y.xls";

while (<IN>){
	/(\S+)\s+(\S+)/;
	my $sp = $1;
	my $x = $2;
	my $lx = 0;
	my $ly = 0;
	my $gx = 0;
	my $gy = 0;
	if (! -e "$sp.fa.fai"){
		`samtools faidx $sp.fa`;
	}
	open I, "$sp.fa.fai";
#	open I, "faSize -detailed $sp.fa|";
	open O1, ">$out/$sp.X.genome";
	open O2, ">$out/$sp.Y.genome";
	while (<I>){
		/(\S+)\s+(\S+)/;
		$lx = $2 if $x eq $1;
		print O1 $_ if $x eq $1;
		$ly = $2 if $1 eq "Y";
		print O2 $_ if $1 eq "Y";
	}
	open I, "$sp.gff";
#	open O, ">genedensity.XY.xls";
	open O1, ">$out/$sp.X.gff";
	open O2, ">$out/$sp.Y.gff";

	while (<I>){
		my $chr = $1 if /(\S+)\s+(\S+)/;
		if ($chr eq $x){
			$gx ++ if $_ =~ /\tgene\t/;
			print O1 $_ if $_ =~ /\tgene\t/;
		}elsif($chr eq "Y"){
			$gy ++ if $_ =~ /\tgene\t/;
			print O2 $_ if $_ =~ /\tgene\t/;
		}
	}
	close O1;
	my $win = 500000;
	`cut -f 1,4,5 $out/$sp.X.gff | awk '{print \$1"\t"\$2"\t"\$3}' > $out/$sp.X.genes.bed`;
	`bedtools makewindows -g $out/$sp.X.genome -w $win > $out/$sp.X.windows`;
	`bedtools coverage -a $out/$sp.X.windows -b $out/$sp.X.genes.bed | cut -f 1-4 > $out/$sp.X.genesden.txt`;
	close O2;
	`cut -f 1,4,5 $out/$sp.Y.gff | awk '{print \$1"\t"\$2"\t"\$3}' > $out/$sp.Y.genes.bed`;
	`bedtools makewindows -g $out/$sp.Y.genome -w $win > $out/$sp.Y.windows`;
	`bedtools coverage -a $out/$sp.Y.windows -b $out/$sp.Y.genes.bed | cut -f 1-4 > $out/$sp.Y.genesden.txt`;
	my $gdX = join "\t", $sp, (split /\s+/, `cat $out/$sp.X.genesden.txt | cut -f 4`);
	my $gdY = join "\t", $sp, (split /\s+/, `cat $out/$sp.Y.genesden.txt | cut -f 4`);
#	chomp $gdX;
	say OUT1 $gdX;
#	chomp $gdY;
	say OUT2 $gdY;
	say OUT join "\t", $sp, $lx, $gx, $ly, $gy;
	
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
