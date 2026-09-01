#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-02-24 10:32:52
	absyw v0.7.3
    Example: abysw.revise.bed.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($ref, $query, $anchor,$size,$bed,$seqsid,$help);
GetOptions(
  "ref:s" =>\$ref,
  "query:s" =>\$query,
  "anchor:s" =>\$anchor,
  "size:s" =>\$size,
  "bed:s" =>\$bed,
  "id:s" =>\$seqsid,
  "help!"=>\&USAGE,)
or USAGE();

if (@ARGV == 2){
	($ref, $query) = @ARGV;
	$anchor = "$ref-$query.simple";
	$size = "$query.info";
	$bed = "$query.bed";
	$seqsid = "$ref.seqids";
}
$anchor ||= shift;
$size ||= shift;
$bed ||= shift;
$seqsid ||= shift;

if (! -e "$ref.seqids"){
	`head -n 1 seqids > $ref.seqids`;
}

my %rev;

my %size;
open IN, $size;
while (<IN>){
	    $size{$1} = $2 if /(\S+).*\s+(\S+)$/;
}

# filter anchors
if (-e "$ref.$query.anchors"){
	open IN, "$ref.$query.anchors";
}elsif (-e "../$ref-$query/synteny-jcvi/$ref.$query.anchors"){
	open IN, "../$ref-$query/synteny-jcvi/$ref.$query.anchors";
	`cp ../$ref-$query/synteny-jcvi/$ref.$query.anchors .`;
}else{
	die "\e[31;01mPlease run jcvi fot get $ref.$query.anchors file first. \e[0m";
}
my %anchs;
while (<IN>){
	$anchs{"$1.$2"} = 1 if /(\S+)\s+(\S+)/;
}

if (-e "$query.$ref.anchors"){
	open IN, "$query.$ref.anchors";
}elsif (-e "../$query-$ref/synteny-jcvi/$query.$ref.anchors"){
	open IN, "../$query-$ref/synteny-jcvi/$query.$ref.anchors";
	`cp ../$query-$ref/synteny-jcvi/$query.$ref.anchors .`;
}else{
	die "\e[31;01mPlease run jcvi fot get $query.$ref.anchors file first. \e[0m";
}
open IN, "$query.$ref.anchors";
while (<IN>){
	if (/(\S+)\s+(\S+)/){
		$anchs{"$2.$1"} = 2 if exists $anchs{"$2.$1"} && $anchs{"$2.$1"} == 1;
	}
}

open IN, "$ref.$query.anchors";
open OO, ">$ref.$query.anchors.f";
my $block = "";
my $check = 0;

while (<IN>){
	if (/(\S+)\s+(\S+)/){
		$check ++ if exists $anchs{"$1.$2"} && $anchs{"$1.$2"} == 2;
		$block .= $_;
#		$n = 0 if exists $anchs{"$1.$2"} && $anchs{"$1.$2"} == 2;
#		$bond = "";
	}else{
		print OO $block if $check > 0;
		$check = 0;
		$block = $_; # if $n == 1;
	}
}
print OO $block if $check > 0;

open IN, "$query.$ref.anchors";
open OO, ">$query.$ref.anchors.f";
$block = "";
$check = 0;
while (<IN>){
#	$n ++;
	if (/(\S+)\s+(\S+)/){
		$check ++ if exists $anchs{"$2.$1"} && $anchs{"$2.$1"} == 2 ;
		$block .= $_;
#		print OO $bond.$_ if exists $anchs{"$2.$1"} && $anchs{"$2.$1"} == 2 ; # 1 if /(\S+)\s+(\S+)/;
#		$n = 0 if exists $anchs{"$2.$1"} && $anchs{"$2.$1"} == 2 ;
#		$bond = "";
	}else{
		print OO $block if $check > 0;
		$check = 0;
		$block = $_;
#		$bond = $_ if $n == 1;
	}
}
print OO $block if $check > 0;

close OO;
#
`python -m jcvi.compara.synteny screen --minspan=0 --simple $ref.$query.anchors.f $ref.$query.anchors.fn`;
`python -m jcvi.compara.synteny screen --minspan=0 --simple $query.$ref.anchors.f $query.$ref.anchors.fn`;

`mv $ref.$query.anchors.simple $ref-$query.simple`;
`mv $query.$ref.anchors.simple $query-$ref.simple`;
#`perl -ne 's/[A-Z][a-z][a-z][a-z][a-z]\_//g; print' $ref.$query.anchors.simple > $ref-$query.simple`;
#`perl -ne 's/[A-Z][a-z][a-z][a-z][a-z]\_//g; print' $query.$ref.anchors.simple > $query-$ref.simple`;

open IN, $anchor;
my %anch;
my %ord;
my @chrs;
my %chr2;
my %sid;
while (<IN>){
	#1_100020.1	1_000044.1	1_101162.1	1_001278.1	65	-
	chomp;
	my @line = split /\s+/, $_;
	my $chr1 = $1 if $line[0] =~ /(\S+)\_[^\s\_]+/;
	my $chr2 = $1 if $line[2] =~ /(\S+)\_[^\s\_]+/;
	$chr1 =~ s/[A-Z][a-z][a-z][a-z][a-z]\_//;
	$chr2 =~ s/[A-Z][a-z][a-z][a-z][a-z]\_//;
	push @chrs, $chr1 if ! exists $anch{$chr1}; 
	$chr2{$chr2} = 1;
	$anch{$chr1}{$chr2} += $line[4];
	$sid{$chr1}{$chr2} = $line[0] if ! exists $sid{$chr1}{$chr2};
	$ord{$chr1}{$chr2} += "$line[5]$line[4]";
}
open O, ">$query.rev";
open O2, ">$anchor.stat";
if ($seqsid){
	@chrs = split /[\s\,]+/, `cat $seqsid`;
}

my @chrs2;
my %chrchr;
my $miss = "";
for my $i (keys %chr2){
	my %chrss2;
	for my $j (@chrs){
		$chrss2{$i}{$j} = $anch{$j}{$i} if exists $anch{$j}{$i};
	}
	if (keys %{$chrss2{$i}} == 0){
		$miss .= ",$i";
		say O2 "######miss $i";
		next;
	}
	my @chrss2 = (sort {$chrss2{$i}{$b} <=> $chrss2{$i}{$a}} keys %{$chrss2{$i}});
	$chrchr{$chrss2[0]} .= "$i,";
	say O2 "$i\t$chrss2[0]\t$anch{$chrss2[0]}{$i}\t$sid{$chrss2[0]}{$i}\t$ord{$chrss2[0]}{$i}";
	say O $i if $ord{$chrss2[0]}{$i} < 0;

}

for (sort {$a cmp $b} keys %chr2){
	push @chrs2, $_;
}
open O, ">$query.seqids";
my $chr2id = "";

open IN, "sort -k 4 $anchor.stat|";
my %newchr;
open OO, ">$query.chrs.bed";
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	say "The error checking $_" if @line < 5;
	next if @line < 5;
	say OO "#Ac$line[1]" if ! exists $newchr{$line[1]};
	say OO "$line[0]\t0\t$size{$line[0]}\t.\t.\t+" if $line[4] >= 0;
	say OO "$line[0]\t0\t$size{$line[0]}\t.\t.\t-" if $line[4] < 0;
	$newchr{$2} .= "$1," if /(\S+)\s+(\S+)/;
	say "$2\t$1\n"
}
for my $i (@chrs){
	if (exists $newchr{$i}){
		$chr2id .= $newchr{$i};
#		$chr2id .= $chrchr{$i};
	}else{
		say "\e[31m# $i miss in species 1\e[0m";
	}
	if (exists $chrchr{$i}){
		say $chrchr{$i};
	}
}
$chr2id .= ",$miss";
$chr2id =~ s/\,\,//g;
$chr2id =~ s/\,*$//;
say O $chr2id;

close O;
close O2;

$anchor = "$query.rev";
if (-e "$query.revs"){
	open IN, "$query.revs";
}else{
	open IN, "$query.rev";
}

while (<IN>){
	chomp;
	my @line = split /\s+/, $_;
	$rev{$1} = 1 if $_ =~ /(\S+)/;
}

open IN, $bed;
#1	35004	35223	1_100001.1	0	+
open O, ">$bed.tmp";
while (<IN>){
	chomp;
	my @line = split /\s+/, $_;
	if (exists $rev{$line[0]}){
#		my @tmp = ($size{$line[0]} - $line[2], $size{$line[0]} - $line[1]);
		#say "$size{$line[0]} - $line[2], $size{$line[0]} - $line[1]";
		(@line[1,2]) = ($size{$line[0]} - $line[2], $size{$line[0]} - $line[1]);
		$line[5] = $line[5] eq "+" ? "-" : "+";
	}
	say O join "\t", @line;
}

#open O, ">sort.anchors.sh";
say  "cat $ref.seqids $query.seqids > seqids";
say  "mv $query.bed.tmp $query.bed";

#say  "mv $ref.$query.anchors.simple $ref-$query.simple";
#say  "mv $query.$ref.anchors.simple $query-$ref.simple";

######################### Sub Routines #########################
sub USAGE{
my $uhead=`pod2text $0`;
my $usage=<<"USAGE";
USAGE:
	perl $0 anchor size bed id
	--help	output help information to screen
USAGE
print $uhead.$usage;
exit;}
