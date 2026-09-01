#!#!/usr/bin/env perl -w
=head1 Info
    Script Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
    Created Time   : 2024-10-10 21:36:00
    Example: abysw.agsyn.func.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($help);
GetOptions(
  "help!"=>\&USAGE,)
or USAGE();

my %hash;
#Aethina_tumida.GCF_024364675.1.genomic.gff3
#Diorhabda_carinulata.GCF_026250575.1.genomic.gff3
#Tribolium_castaneum.GCF_000002335.3.genomic.gff3

#`grep -P "\tgene\t" reference/Aethina_tumida.GCF_024364675.1.genomic.gff3 > Aethina_tumida.gene`;
#`grep -P "\tgene\t" reference/Diorhabda_sublineata.GCF_026230105.1.genomic.gff3 > Diorhabda_sublineata.gene`;
#`grep -P "\tgene\t" reference/Diorhabda_carinulata.GCF_026250575.1.genomic.gff3 > Diorhabda_carinulata.gene`;
#
my %hash1;
for my $ref (split /\s+/, `ls func_refs/*gff`){
	$ref =~ s/.gff$//;
	$ref =~ s/func_refs\///;
	my %hash;
	open IN, "func_refs/$ref.gff";
	while (<IN>){
		if (/\tgene\t/){
			$hash{$1} = $_ if /=([^\s\;]+)/;
		}
	}
	open O1, ">agsx.func.$ref.xls";
	open IN, "Orthogroups.tsv";
	while (<IN>){
		my @line = split /[\s\,]+/, $_;
		my $check = "\t\t";
		for (@line){
			if (/(\S+)\./){
				if (exists $hash{$1}){
					open O, ">$1.gff";
					print O $hash{$1};
					close O;
					my $loc = `bedtools intersect -a $1.gff -b func_refs/$ref.gene -wb`; # =~ /ID=([^\n\;\t]+).*description=([^\n\;\t]+)/;
					`rm $1.gff`;
					$check = $1 if $loc =~ /gene=([^\n\;\t]+)/;
					$check .= "\t";
					$check .= $1 if $loc =~ /description=([^\n\;\t]+)/;
					#`rm $1.gff`;
					$hash1{$ref}{$line[0]} = $check;
					last if $loc =~ /description=([^\n\;\t]+)/;
				}
			}
		}
		say O1 "$line[0]\t$check";
	}
}

open IN, "agsx.OG.XYSA.sorted.xls";
open O, ">agsx.OG.XYSA.sorted.func.xls";
print "OG_ID\t";
say O join "\t\t", sort {$a cmp $b} keys %hash1;
while (<IN>){
	chomp;
	/(\S+)/;
	print O $_;
	for (sort {$a cmp $b} keys %hash1){
		print O exists $hash1{$1} ? "\t$hash1{$1}": "\t\t\t";
	}
	say O;
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
