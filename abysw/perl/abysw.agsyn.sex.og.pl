#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-07-11 05:36:46
    Example: abysw.agsyn.agsx.og.pl -x 0.95 -y 15 Orthogroups.tsv
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($xsp, $ysp, $help);
GetOptions("xsp:f" =>\$xsp,
  "ysp:i" =>\$ysp,
  "help!"=>\&USAGE,)
or USAGE();


$xsp ||= 0.95;
$ysp ||= 15;
my $file_og = "Orthogroups.tsv";
$file_og ||= shift;
die "please prepare sexchr and Orthogroups.tsv first!!!" if ! -e "sexchr" || ! -e $file_og;
open IN, "sexchr";
open O, ">Orthogroups.tsv.top";
my %hash;
my %sort;
my $n = 0;
while (<IN>){
	$hash{"$2$3\_$4"} = $1 if /((\w\w)\w+\_(\w\w\w)\w+)\s+(\S+)/;
	$n ++;
	$sort{$1} = $n;
	say STDERR "$1\t $2$3\_$4";
}

open IN, $file_og;
my $head = <IN>;
chomp $head;
$head =~ s/Diorhabda_carinata/Diorhabda_agsyncarinata/;
my %order;
my @head = split /\t/, $head;
for my $j (1..$#head){
	$head[$j] = $1 if $head[$j]=~/(\w+)/;
	$order{$j} = $sort{$head[$j]};
#	say STDERR "$head[$j]\t$order{$j}\t$j}";
}

print O "$head[0]\tchr";            for my $i (sort{$order{$a} <=> $order{$b}} keys %order){        print O "\t$head[$i]";} print O "\n";
#print STDERR  "$head[0]\tchr";    for my $i (sort{$order{$a} <=> $order{$b}} keys %order){        print STDERR "\t$i\t$order{$i}";} print O "\n";

open OOO, ">agsx.OG.XYSA.xls";
while (<IN>){
	chomp;
	my $x = 0;
	my $y = 0;
	my $aa = 0;
	my $s = 0;
	my @line = split /\t/, $_;
	my (@xs, @ys, @as, @ss);
	my $num = 0;
	my $nux = 0;
	my $nuy = 0;
	my $nua = 0;
	my $nus = 0;
	for my $i (@line[1..$#line]){
		my @l = split /[\,\s]+/, $i;
		$x = $y = $s = $aa =0;
		for (@l){
			$num ++;
			my $chr = "";
			if (/(\S+)\_/){
				$chr = $1;
			}else{
				next;
			}

			if (exists $hash{$chr}){
				$x = 1;
			}elsif($chr =~ /_Y$/){
				$y = 1;
			}elsif(length($chr) > 10){
				$s = 1;
			}elsif(length($chr) > 5){
				$aa = 1;
			}
		}
		push @xs, $x;
		push @ys, $y;
		push @as, $aa;
		push @ss, $s;
		$nux += $x;
		$nuy += $y;
		$nus += $s;
		$nua += $aa;
	}
#	next if $num/($#line) > 5;
	say OOO "$line[0]\t$nux\t$nuy\t$nus\t$nua";
	next if ($nux < ($#line) * $xsp && $nuy < $ysp);
#	print "$line[0]\tO";	for my $i (sort{$order{$a} <=> $order{$b}} keys %order){		print "\t$line[$i]";} print "\n";
	print O "$line[0]\tX";	for my $i (sort{$order{$a} <=> $order{$b}} keys %order){		print O "\t$xs[$i-1]";} print O "\n";
	print O "$line[0]\tY";    for my $i (sort{$order{$a} <=> $order{$b}} keys %order){        print O "\t$ys[$i-1]";} print O "\n";
	print O "$line[0]\tS";    for my $i (sort{$order{$a} <=> $order{$b}} keys %order){        print O "\t$ss[$i-1]";} print O "\n";
	print O "$line[0]\tA";    for my $i (sort{$order{$a} <=> $order{$b}} keys %order){        print O "\t$as[$i-1]";} print O "\n";
}

close O;
close OOO;
sleep 1;

`less agsx.OG.XYSA.xls | sort -k2,2nr -k5,5n  > agsx.OG.XYSA.sorted.xls`;
sleep 1;

open IN, "Orthogroups.tsv.top";
open O, ">agsx.OG.XYSA.top.agsx";

%hash = ();
$head = <IN>;
my $num_sps =(split /\t/, $head) - 2;
say $num_sps;

print O $head;
while (<IN>){
        $hash{$1} .= $_ if /(\S+)/;
}

my $file = "";
open IN, "agsx.OG.XYSA.sorted.xls";
my %uniq;
while (<IN>){
        /(\S+)/;
        $file = "$hash{$1}$file" if exists $hash{$1};
		chomp;
		my @line = split /\t/, $_;
		$uniq{"X"}{$line[1]} ++;
		$uniq{"Y"}{$line[2]} ++;
		$uniq{"S"}{$line[3]} ++;
		$uniq{"A"}{$line[4]} ++;
}
print O $file;
open O, ">agsx.OG.XYSA.stat.txt";

for my $i (0..$num_sps){
	print O $i;
	print O exists $uniq{"X"}{$i} ? "\t".$uniq{"X"}{$i} : "\t0";
	print O exists $uniq{"Y"}{$i} ? "\t".$uniq{"Y"}{$i} : "\t0";
	print O exists $uniq{"S"}{$i} ? "\t".$uniq{"S"}{$i} : "\t0";
	print O exists $uniq{"A"}{$i} ? "\t".$uniq{"A"}{$i} : "\t0";
	print O "\n";
}

close O;



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
