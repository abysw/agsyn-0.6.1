#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-05-27 14:10:12
    Example: abysw.agsyn.syn.pl ref qur [2000000] [--dellen 8]
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($log, $dellen, $help);
GetOptions(
  "dellen:i" =>\$dellen,
	"log!" =>\$log,
  "help!"=>\&USAGE,)
or USAGE();

my $ref = shift;
my $qur = shift;
my $lact = shift;
$lact ||= 2000000;
$dellen ||= 8; # in beeltes
my $rcol = "$ref.acol";
open IN, "$ref.acol";
my %region;
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	$region{$line[0]}{"$line[1]__$line[2]"} = "$line[-2]__$line[-1]";
}
my $rbed = "$ref.bed";
my %greg;
my %gcol;
open IN, $rbed;
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	$greg{$line[3]} = "$line[1]__$line[2]";
	if (exists $region{$line[0]}){
		for my $i (keys %{$region{$line[0]}}){
			$i =~ /(\d+)__(\d+)/;
			if ($line[1] >= $1 && $line[1] <= $2){
				$gcol{$line[3]} = $region{$line[0]}{$i};
				last;
			}
		}
	}
}

my $qbed = "$qur.bed";
my (%start, %end, %chr);
open IN, $qbed;
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	$start{$line[3]} = $line[1];
	$end{$line[3]} = $line[2];
	$chr{$line[3]} = $line[0];
}

my $qseqids = "$qur.seqids";
my @ids = (split /\,/, `cat $qseqids`);
open IN, "$qur.info";
my %qlen;
my $gap_len = 0;
while (<IN>){
	$qlen{$1} = $2 if /(\S+)\s+\S+\s+(\d+)/;
	delete $qlen{$_} if length($1) > $dellen; # In beetles
	$gap_len += $2;
}
my %clen;
my $len = 0;

$gap_len = int($gap_len / 150) ;
#$gap_len = 5000000;

##############################################################
my $achr = "";
my $aags = "";
my $asim = "";
my $aact = "";
my $asex = "";
my $y = "";
##########################################################
for (@ids){
	chomp;
	next if ! exists $qlen{$_};
	if ($qlen{$_} < $lact/2){
		delete $qlen{$_};
		next;
	}
	if (length($_) > $dellen){
		delete $qlen{$_};
		next;
	}
	chomp;
	if (/W$/){
#	if (/Y/){
		$y = $_;
		next;
	}
	$clen{$_} = $len;
	$achr .= join "\t", $qur, $len, $qlen{$_} + $len, "chr", ".", "$_", "black\n";
	$aags = join "\t", $qur, $len, $qlen{$_} + $len, "chr", ".", "$_", "black\n";
	#say O join "\t", $qur, $len, $qlen{$_} + $len, "chr", ".", "$_", "black";
	$len += $qlen{$_} + $gap_len;
}
if ($y =~ /\S+/){
	$clen{$y} = $len;
	$achr .= join "\t", $qur, $len, $qlen{$y} + $len, "chr", ".", "$y", "black\n";
}

#open O, ">$qur.achr";
#print O $achr;

#################################
my $sim = "$ref-$qur.simple";
open IN, $sim;
#open O, ">$qur.asim";
open O1, ">$qur.atmp";
open O2, ">$qur.atmp1";
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	my @reg = sort {$a <=> $b} ($start{$line[2]}, $start{$line[3]}, $end{$line[2]}, $end{$line[3]});
	if (! exists $gcol{$line[0]}){
#		say "\e[32m $line[0]\e[0m";
		next;
	}
	if (exists $clen{$chr{$line[2]}}){
		$asim .= join "\t", $qur, $reg[0] + $clen{$chr{$line[2]}}, $reg[-1] + $clen{$chr{$line[2]}}, "gene$line[4]", ".", (split /__/, $gcol{$line[0]});
		$asim .= "\n";
	}
#	say O join "\t", $qur, $reg[0] + $clen{$chr{$line[2]}}, $reg[-1] + $clen{$chr{$line[2]}}, "gene$line[4]", ".", (split /__/, $gcol{$line[0]}) if exists $clen{$chr{$line[2]}};
	say O1 join "\t", $chr{$line[2]}, $reg[0], $reg[-1], "gene$line[4]", ".", (split /__/, $gcol{$line[0]});
}
my $qcol = "$qur.acol";
my $tmp = "";
my $tmpcol;
if (! -e $qcol){
	open IN, "cat $qur.atmp | sortBed -i - |";
	my %qchr;
	my $chr;
	while (<IN>){
		chomp;
		my @line = split /\t/, $_;
#		$chr = $line[0];
		if (! exists $qchr{$line[0]}){
			say O2 join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "genes", ".", $tmpcol if $chr;
#			say join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "genes", ".", $tmpcol if $chr;
			$chr = $line[0];
			$qchr{$chr}{"$line[-2]__$line[-1]_s"} = $line[1];
			$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
			$tmp = "$line[-2]__$line[-1]";
			$tmpcol = "$line[-2]\t$line[-1]";
		}elsif (! exists $qchr{$chr}{"$line[-2]__$line[-1]_s"}){
			say O2 join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "genes", ".", $tmpcol;
			delete $qchr{$chr}{"$tmp\_s"};
			$qchr{$chr}{"$line[-2]__$line[-1]_s"} = $line[1];
			$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
			$tmp = "$line[-2]__$line[-1]";
			$tmpcol = "$line[-2]\t$line[-1]";
		}else{
			$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
		}
	}
	say O2 join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "genes", ".", $tmpcol;
}

open IN, "awk '\$3-\$2 > 250000' $qur.atmp1 |";
my %qchr = ();
my $chr;
close O2;
#open O, ">$qur.aact";
my $qucol;
open O2, ">$qur.atmp2";
while (<IN>){
	chomp;
	my @line = split /\t/, $_;
	if (! exists $qchr{$line[0]}){
		say O2 join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "act", ".", $tmpcol if $chr;
		if ($chr && exists $clen{$chr}){
			$aact .= join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol;
			$qucol.= join "\t", $chr, $qchr{$chr}{"$tmp\_s"} , $qchr{$chr}{"$tmp\_e"}, "act", ".", $tmpcol;
			$qucol.= "\n";
			$aact .= "\n";
		}
#		say O join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol if $chr && exists $clen{$chr};

		$chr = $line[0];

		$qchr{$chr}{"$line[-2]__$line[-1]_s"} = $line[1];
		$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
		$tmp = "$line[-2]__$line[-1]";
		$tmpcol = "$line[-2]\t$line[-1]";
	}elsif (! exists $qchr{$chr}{"$line[-2]__$line[-1]_s"}){
		next if $line[2] - $line[1] < $lact;
#		say O join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "act", ".", $tmpcol;
		if (exists $clen{$chr}){
			$aact .= join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol;
			$aact .= "\n";
			$qucol .= join "\t", $chr, $qchr{$chr}{"$tmp\_s"} , $qchr{$chr}{"$tmp\_e"} , "act", ".", $tmpcol;
			$qucol .= "\n";
		}
#		say O join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol if exists $clen{$chr};
		delete $qchr{$chr}{"$tmp\_s"};
		$qchr{$chr}{"$line[-2]__$line[-1]_s"} = $line[1];
		$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
		$tmp = "$line[-2]__$line[-1]";
		$tmpcol = "$line[-2]\t$line[-1]";
	}else{
		$qchr{$chr}{"$line[-2]__$line[-1]_e"} = $line[2];
	}
}
#say O join "\t", $qur, $reg[0] + $clen{$chr{$line[2]}}, $reg[-1] + $clen{$chr{$line[2]}}, "gene$line[4]", ".", (split /__/, $gcol{$line[0]});

if (exists $clen{$chr}){
	$aact .= join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol;
	$aact .= "\n";
	$qucol .= join "\t", $chr, $qchr{$chr}{"$tmp\_s"} , $qchr{$chr}{"$tmp\_e"} , "act", ".", $tmpcol;
	$qucol .= "\n";
}
#say O join "\t", $qur, $qchr{$chr}{"$tmp\_s"} + $clen{$chr}, $qchr{$chr}{"$tmp\_e"} + $clen{$chr}, "act", ".", $tmpcol if exists $clen{$chr};
say O2 join "\t", $chr, $qchr{$chr}{"$tmp\_s"}, $qchr{$chr}{"$tmp\_e"}, "act", ".", $tmpcol;

if (`ls $qur*gff 2> /dev/null`){
	`ls $qur*gff` =~ /(\S+)/;
	open IN, "$1";
#	open O, ">$qur.asex";
	while (<IN>){
		chomp;
		my @line = split /\t/, $_;
		next if $line[2] ne "mRNA";
		my $tmpcol = "grey";
		if ($line[8] =~ /sxl/){
			$tmpcol = "sxl\tpurple";
		}elsif($line[8] =~ /fru/){
			$tmpcol = "fru\tgrey";
		}elsif($line[8] =~ /dsx/){
			$tmpcol = "dsx\tred";
		}elsif($line[8] =~ /tra/){
			$tmpcol = "tra\tcyan";
		}elsif($line[8] =~ /elav/){
			$tmpcol = "elav\tblue";
#		}elsif($line[8] =~ /XB/){
#			$tmpcol = "tra\tblue";
		}
		$chr = $line[0];
		if (exists $clen{$chr}){
			$asex .= join "\t", $qur, $clen{$chr} + $line[3], $clen{$chr} + $line[4], "sex", ".", $tmpcol;
			$asex .= "\n";
		}
#		say O join "\t", $qur, $clen{$chr} + $line[3], $clen{$chr} + $line[4], "sex", ".", $tmpcol if exists $clen{$chr};

	}
}
close;
#`cp $qur.tmp2 $qur.acol`;
#`cat $qur.asim $qur.aact $qur.asex $qur.achr >> $qur.agsyn`;
open O, ">$qur.agsyn";
print O $aags;
print O $asim;
print O $aact;
print O $asex;
print O $achr;

open O, ">$qur.acol.tmp";
print O $qucol;
close;
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
