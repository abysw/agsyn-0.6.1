#!/bin/bash
# File Name: abysw.gwise.sh
# Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
# Created Time: 2024-01-03 11:31:49
# Please find more information in abysw.com or github(abysw)

P=$1 # protein
G=$2 # genome
M=$3 # d b m
S=$4 # simple repeat
C=$5 # cpu

[[ ! $M ]] && M=b
[[ ! $S ]] && S=0.2
[[ ! $C ]] && C=10
pwd=$PWD
rm -rf gen*
echo "$P $G $M $S $C"

#export PATH=~/.abysw/ABYSsWrapper/combin/MT_annotation_BGI:$PATH
export PATH=~/.abysw/ABYSsWrapper/combin:$PATH  # blastall formatdb
export WISECONFIGDIR=~/.abysw/soft/wise2.4.1/wisecfg
export PATH=~/.abysw/soft/wise2.4.1/src/bin:$PATH

#############################################################################
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mPreparing step: \e[m\n\t\tfiles: $G $P\n"
mkdir match-$M
cd-hit -i $P -o match-$M/$P &> /dev/null
tantan -x n -s $S $G > match-$M/$G
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mFirst step: \e[mmatching\n"
cd match-$M
################# diamond blastx ##############
if [ $M == "d" ]; then
	diamond makedb -d $P --in $P 2>/dev/null
	diamond blastx -b 0.5 -d $P -q $G -o $G.blast --threads $C 2> /dev/null
	less $G.blast | perl -ne 'chomp; @l=split; print join "\t", $l[1],"0", $l[0], "0", @l[8,9,6,7], int($l[11] + 0.5), $l[10]; print "\n";' > $G.match
fi
################ tblastn #####################
if [ $M == b ]; then
	formatdb -i $G -p F && \
	tblastn -db $G -query $P -evalue 1e-5 -outfmt 6 -num_threads $C > $G.blast
	awk '$3>30' $G.blast | perl -ne 'chomp; @l=split; print join "\t", $l[0],"0", $l[1], "0", @l[6..9], int($l[11] + 0.5), $l[10]; print "\n";' > $G.match
fi
################ mummer #####################
if [ $M == m ]; then
	nucmer -b 1000 -c 50 -p $G $P $Q
	show-coords -TH $G.delta | perl -ne 'chomp; @l=split; print join "\t", $l[7],"0", $l[8], "0", @l[0..3], int($l[6] + 0.5), $l[6]; print "\n";' > $G.match
fi
################################################################################
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mSecond step: \e[mobtaining the best match\n"
############## get match
less $G.match | solar -n 100000 -d -1 -c -C |\
	perl -ne 'chomp; @l=split; next if $l[10] < 25; $a=0; for (split /\;/, $l[11]){$a+=abs($2-$1)+1 if /(\d+),(\d+)/;} next if $a/$l[1] < 0.25; $h{$l[0]}++; $l[0] = "$l[0]-D$h{$l[0]}" if $h{$l[0]} > 1; print join "\t", @l; print"\n"' | sort > $G.solar

less $G.solar | perl -ne '@l = split; @l[4,5] = @l[5,4] if $l[4] > $l[5]; print join "\t", @l[5,7,8,0,10,4], $l[3]-$l[2]+1, $l[10]; print "\n"' | sortBed -i - | tee $G.solar.bed | mergeBed -i - -d 100 > $G.solar.merged.bed

bedtools intersect -a $G.solar.bed -b $G.solar.merged.bed -wb | sort -k 5nr | perl -ne '@l=split; next if $l{"$l[8].$l[9]"}; $l[1]-=2000; $l[1] = 0 if $l[1] < 0; $l[2] += 2000; print join "\t", @l[0..5]; print "\n";$l{"$l[8].$l[9]"} = $l[6]; ' | sortBed -i - > $G.solar.nr.bed
cp $G.solar.nr.bed ../$G.bmatch.bed
cd ..

##########################################################
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mThird step: \e[mpreparing sequcencs\n"
mkdir genome
bedtools getfasta -name -fi $G -bed $G.bmatch.bed -fo | sed s/[\:]/\_/g > genome/genome.fa
cd genome && abysw split.chrs genome.fa && rm genome.fa && cd ..

mkdir protein
cut -f 4 $pwd/$G.bmatch.bed | awk -F "-D" '{print $1}' > protein/gene.list
abysw getfa protein/gene.list $pwd/$P > protein/protein.fa 2> /dev/null
cd protein && abysw split.chrs protein.fa && rm gene.list protein.fa && cd ..

perl -ne 'print "cp protein/$2.fa protein/$1.fa\n" if /\t((\S+)\-D\d+)\t/ ' $G.bmatch.bed |sh 

###############################################################
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mFourth step: \e[mannotating by genewise\n"
mkdir genewise

perl -ne 'if (/(\S+)\s+(\d+)\s+([+-])$/){print "genewise -"; print $3 eq "+" ? "tfor" : "trev"; print " -genesf -gff -sum protein/$1.fa genome/$1\__*fa\n"}' $G.bmatch.bed |sh > $G.genewise
#for i in `ls genome | grep __`;do 
#	PP=`echo $i | perl -ne 'print $1 if /(\S+)__/'`;
#	while [ $(jobs -p | wc -l) -ge 10 ]; do sleep 1; done
#	genewise -tfor -genesf -gff -sum protein/$PP.fa genome/$i > genewise/$i.genewise
#done 

#cat genewise/*genewise > $P.genewise

### wise to gff
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mFifth step: \e[mconversing coordinates\n"
less $G.genewise | perl -ne 'if (/(^Bits)/){($sc,$id) = ($1,$2) if <>=~ /(\S+)\s+(\S+)/; $cds=""; $stt = 0; $edd = 0; $i=0; $od = "+";}	chomp; @l=split; if ($l[1] eq "GeneWise" && @l == 9){($chr,$st,$ed) = ($1,$2,$3) if $l[0] =~ /__(\S+)\_(\d+)\-(\d+)$/; $l[3] += $st; $l[4] += $st; $stt = $l[3] if $stt == 0; $edd = $l[4]; $od = $l[6]; @l[3,4] = @l[4,3] if $l[3] > $l[4]; $l[8] = "Parent=$chr\_$st\_$id.1;"; next if $l[2] ne "cds"; $l[2] = "CDS"; $cds .= join "\t", $chr, @l[1..8]; $cds.="\n";} $i++ if m#^//#; if ($i==3){	($stt,$edd) = ($edd,$stt) if $stt > $edd; @l[3,4] = ($stt,$edd); print join "\t", $chr, "GeneWise","gene",$stt,$edd, $sc, $od, ".", "ID=$chr\_$st\_$id;"; print "\n"; print join "\t", $chr, "GeneWise","mRNA",$stt,$edd, $sc, $od, ".", "ID=$chr\_$st\_$id.1;Parent=$chr\_$st\_$id;"; print "\n"; print $cds;}' > $G.genewise.gff

grep -P "\tgene\t" $G.genewise.gff | sortBed -i - | perl -ne 'chomp; @l=split; $h{$l[0]}++; print "$1\t" if $l[-1] =~ /=(\S+);/; print "$l[0]\_" . "0" x (6-length($h{$l[0]})); print "$h{$l[0]}\n"' > $G.genewise.new.id

#echo $P | perl -ne 'chomp; $p=$_; %h=split /\s+/, `cat $p.genewise.new.id`; @l = split /\n/, `cat $p.genewise.gff`; for (@l){ $i = $1 if /=(\S+);/; $i = $1 if /=(\S+)\.\d;/; s/$i/$h{$i}/g if exists $h{$i}; print "$_\n"}'> $G.gff
echo $G | perl -ne 'chomp; $p=$_; %h=split /\s+/, `cat $p.genewise.new.id`; @l = split /\n/, `cat $p.genewise.gff`; for (@l){ $i = $1 if /=([^\s\;]+)\.\d;/; s/$i/$h{$i}/ if exists $h{$i}; print "$_\n"}'> $G.gff

###################################################
echo -ne "`date +%Y/%m/%d\ %H:%M:%S` \e[32;01mSixth step: \e[mproducting results\n"
mkdir result
S=`echo $G | perl -ne 'print $1 if /(\w+)/'`;
N=`echo $G | perl -ne 'print "$1$2" if /(\w\w)\w+\_(\w\w\w)/'`;
abysw c.gff $G.gff | sed s/\_$N\_//g > result/$S.gff
abysw c.fa $G | sed s/\_$N\_//g > result/$S.fa
gffread result/$S.gff -g result/$S.fa -x result/$S.cds -y result/$S.pep

