#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-02-14 15:32:51
    Example: abysw.achor.chrs.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($overlap, $merge, $length, $help);
GetOptions(
	"overlap:f" =>\$overlap,
	"merge:i" =>\$merge,
	"length:i" =>\$length,
  "help!"=>\&USAGE,)
or USAGE();

my $chr = shift;
my $contig = shift;
my %check;
$overlap ||= 0.3;
$merge ||= 100;
$length ||= 1000;

my %size;# = split /\s+/, `faSize --detial $contig`;
`minimap2 -cx asm20 -t 32 $chr $contig > $chr.$contig.paf`if (! -s "$chr.$contig.paf");
open IN, "$chr.$contig.paf";
mkdir "$contig.dir";
while (<IN>){
	my @line = split /\t/, $_;
	my $id = $line[0];
	if (! exists $check{$line[0]}){
		open O1, ">$contig.dir/$id.p.bed";
		open O2, ">$contig.dir/$id.m.bed";
		$check{$id} = 1;
		$size{$id} = $line[1];
	}
	if ($line[4] eq "+"){
		say O1 join "\t", @line[5,7,8];
	}else{
		say O2 join "\t", @line[5,7,8];
	}
}
close IN;
close O1;
close O2;

open O, ">$contig.tmp.bed";

for my $id (keys %size){
#	`sortBed -i $contig.dir/$id.p.bed > $contig.dir/$id.p.bed.s`;
#	`mergeBed -d 1000 -i $contig.dir/$id.p.bed.s > $contig.dir/$id.p.bed.sm`;
#	`sortBed -i $contig.dir/$id.m.bed > $contig.dir/$id.m.bed.s`;
#	`mergeBed -d 1000 -i $contig.dir/$id.m.bed.s > $contig.dir/$id.m.bed.sm`;
#	open IN, "sortBed -i $contig.dir/$id.p.bed| mergeBed -d $merge -i - | awk '\$3-\$2>$size{$id}/10'|awk '{print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$3-\$2}'| sort -k 4 -nr|";
	open IN, "sortBed -i $contig.dir/$id.p.bed| mergeBed -d 100 -i - | awk '\$3-\$2>500' | mergeBed -d $merge -i - | awk '\$3-\$2>$size{$id}/10' | awk '{print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$3-\$2}'| sort -k 4 -nr|";
	my $i = 0;
	my %lines;
	my ($p,$m);
	while (<IN>){
		$i++;
		@{$lines{$i}} = split /\t/, $_;
		last if $i>2;
	}
	if ($i == 1){
		$p = join "\t", $id, "0", "$size{$id}", ".", ".", "+", @{$lines{1}};
	}elsif($i == 2){
		if (${$lines{2}}[0] eq ${$lines{1}}[0]){
			$p = join "\t", $id, "0", "$size{$id}", ".", ".", "+", @{$lines{1}};
		}elsif(${$lines{1}}[3] - ${$lines{2}}[3] > $length){
			$p = join "\t", $id, "0", "$size{$id}", ".", ".", "+", @{$lines{1}};
		}
	}
	open IN, "sortBed -i $contig.dir/$id.m.bed| mergeBed -d 100 -i - | awk '\$3-\$2>500' | mergeBed -d $merge -i - | awk '\$3-\$2>$size{$id}/10' | awk '{print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$3-\$2}'| sort -k 4 -nr|";
	$i = 0;
	%lines = ();
	while (<IN>){
		$i++;
		@{$lines{$i}} = split /\t/, $_;
		last if $i>2;
	}
	if ($i == 1){
		$m = join "\t", $id, "0", "$size{$id}", ".", ".", "-", @{$lines{1}};
	}elsif($i == 2){
		if (${$lines{2}}[0] eq ${$lines{1}}[0]){
			$m = join "\t", $id, "0", "$size{$id}", ".", ".", "-", @{$lines{1}};
		}elsif(${$lines{1}}[3] - ${$lines{2}}[3] > $length){
			$m = join "\t", $id, "0", "$size{$id}", ".", ".", "-", @{$lines{1}};
		}
	}
	my $table = "";
	if ($p && $m){
		my $lp = $1 if $p =~ /(\d+)$/;
		my $lm = $1 if $m =~ /(\d+)$/;
		if (abs($lp - $lm) >= $length){
			$table = $p if $lp - $lm > 0;
			$table = $m if $lp - $lm < 0;
		}
	}else{
		$table = $p if $p;
		$table = $m if $m;
	}
	chomp $table;
	my @tab = split /\s+/, $table;
	if (@tab > 3){
		say O join "\t", @tab[6..8,0..5] if ($tab[9] > $size{$tab[0]} * $overlap);
	}

}
close O;
`rm -rf $contig.dir`;
open IN, "sortBed -i $contig.tmp.bed|";
open O, ">$contig.chrs.bed";
my %chr;
my $len = 0;
while (<IN>){
	chomp;
	my @ls = split /\t/, $_;
	if (! exists $chr{$ls[0]}){
		say O "#Achr$ls[0]";
		$chr{$ls[0]} = 1;
		$len = 0;
	}
	$len += $ls[5];
	say O join "\t", @ls[3..6], $len, $ls[8];
	$len += 100;
}

######################### Sub Routines #########################
#VHLT010000126.1	27658	2097	27658	-	8	14070832	8945345	8970906	25561	25561	60	NM:i:0	ms:i:25561	AS:i:25561   nn:i:0	tp:A:P	cm:i:4571	s1:i:25336	s2:i:7357	de:f:0	rl:i:2508	cg:Z:25561M
#
sub USAGE{
my $uhead=`pod2text $0`;
my $usage=<<"USAGE";
USAGE:
	perl $0
	--help	output help information to screen
USAGE
print $uhead.$usage;
exit;}
