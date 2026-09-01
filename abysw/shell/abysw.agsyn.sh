#!/bin/bash
# File Name: abysw.agsyn_v0.5.sh
# Author  : yuanfu, Yuan-SW-F, abysw@abysw.com
# Created Time: 2024-01-06 17:28:58
# Please find more information in abysw.com or github(abysw)

########################################################################################
##################Run test in 1 core on login node #####################################
########################################################################################
#species				GenomeSize	 GS(noNs)	FileSize	ORFfinderTime	TotalRunTime	
#Agelastica_alni		 692286867	 692237867	669M     49m    0:55
#Bruchidius_siliquastri	 372085036	 372070836	360M     40m    0:45
#Chrysolina_americana	 980590408	 980508408	947M     86m    1:34
#Chrysolina_oricalcia	1423453393	1423368593	1.4G    120m    2:10
#Crepidodera_aurea		 508975589	 508926789	492M     30m    0:35
#Crioceris_asparagi		 634247594	 634215394	613M     46m   ~0:55
#Cryptocephalus_moraei	 500560161	 500534961	484M     33m    0:38
#Diabrotica_virgifera	2533404242	2533094815	2.4G    175m    3:12
#Diorhabda_carinata		 437827291	 437824791	423M     30m    0:35
#Monochamus_saltuarius	 682219095	 682165934	659M     45m    0:51
#Rutpela_maculata		2021580433	2021404433	2.0G	178m	3:16
########################################################################################
##A fasta way (~1min/10Mb) for get genesets location and syntenic block among species###
########################################################################################
#	For plant genomes, it may take 1.5 times more time for find ORF.
#	For more useful deyails, I sugest you prepare protein of closer lineage specise,
#	or use several proteins from different species.
#	May you a nice experence. Good Luck!
########################################################################################

if [ $1 == "help" ];then 
	cat ~/.abysw/ABYSsWrapper/shell/abysw.agsyn.README
	exit
fi

G=$1
P=$2
T=$3

[[ $G ]] && [[ -e $G ]] && mkdir genome && cp $G genome
[[ $P ]] && [[ -e $P ]] && mkdir protein && cp $P genome
[[ ! $T ]] && T=0

if ([ ! -e genome ]); then
	echo -ne "\e[31;01mplease prepare the required directorys of \"genome\" and \"protein\", 
	please put the qurey genomes in directory \"genome\",
	and please put the homolog proteins in directory \"protein\",
	all of genome sequence files shoud named as Genus_species.*\n\n"
	echo -ne "\e[32;01mOtherwise, you can try to use: abysw orfsyn Genus_species protrin.pep"
	exit
fi

if ([ -e 00.prepare ]);then
	echo -ne "\e[31;01mWaring: the 00.prepare/homolog.pep already exists, you have 30 secends to cancel this job, otherwise we will update this file!\n"
	sleep 30
else
	mkdir 00.prepare
fi

[[ -e homolog.pep ]] && rm homolog.pep
for i in `ls protein/*`;do
	if [ -f $i ];then
		[[ `grep \> $i` ]] && cat $i >> homolog.pep
	fi
done
P=homolog.pep
mkdir time
for i in `ls genome | grep -P "\.fa$"`;do 
	G=$i
	if ([ -e time/$G.time ]); then
		echo -ne "\e[31;05;01mthe tast of genome $G maybe started before, we will skip this task!\n\n\e[m"
		continue
	fi
	DATA=`date +%Y-%m-%d--%H:%M:%S` 
	echo -ne "$G\t$DATA\t" > time/$G.time

	if ([ -e genome/$G.fai ]); then
		echo -ne "\e[31;05;01mthe tast of genome $G maybe finished before, we will skip this task!\n\n\e[m"
		continue
	fi

if [[ -e genome/$G && -e $P ]];then 
	echo -ne "\n\e[32;01mParameter: G:$G P:$P T:$T\n\e[m"
else
	echo -ne "\e[31mNo input files: $G. Please use: abysw orffinder genome protein [0]\n\e[m"
	continue
fi

[[ ! -d finished ]] && mkdir finished
echo -ne "\e[33m`date +%Y/%m/%d\ %H:%M:%S` Prepare genome\e[m\n"
abysw splitbytantan genome/$G > 00.prepare/$G.split
# birds
#tantan genome/$G > 00.prepare/$G.tantan
#bedtools getfasta -fi 00.prepare/$G.tantan -bed 00.prepare/$G.split -fo | sed s/[\:\-]/\_/g > 00.prepare/$G.split.fa
# beetles
bedtools getfasta -fi genome/$G -bed 00.prepare/$G.split -fo | sed s/[\:\-]/\_/g > 00.prepare/$G.split.fa 
[[ ! -e 00.prepare/$P ]] && cd-hit -i $P -o 00.prepare/$P

cd 00.prepare
echo -ne "\e[33m`date +%Y/%m/%d\ %H:%M:%S` Finding ORF\e[m\n"
export LD_LIBRARY_PATH=/proj/snic2020-2-25/nobackup/yuan/miniconda3/envs/agsyn/lib:$LD_LIBRARY_PATH
time /proj/snic2020-2-25/nobackup/yuan/02.insects/08.orf/ORFfinder -in $G.split.fa -s $T -ml 75 -out $G.split.pep # 71m 45m
export LD_LIBRARY_PATH=

echo -ne "\e[33m`date +%Y/%m/%d\ %H:%M:%S` Filtering bad macthes\e[m\n"
if [[ -e $P ]];then
	diamond makedb --db $G.split.pep --in $G.split.pep # 50s
	diamond blastp -d $G.split.pep -q $P -o $G.split.pep.blast --threads 1 # 2m
fi


cut -f 1,2 $G.split.pep.blast | perl -ne '$nm=$1 if /(\S+)/; if (/\S+ORF\d+\_(\S+)\_(\d+)\_(\d+):(\d+):(\d+)/){$a=$4+$2; $b=$5+$2; $a+=1; $b+=1; $std = "+"; $i++; }if ($a < $b){print join "\t", $1, "ORFfinder", "CDS", $a, $b, ($b-$a)/100, $std, ".", "ID=" . "$1\_ORF_".("0" x (6-length($i)))."$i;NAME=$nm;"; print "\n";}else{($a,$b)=($b,$a); $std = "-"; print STDERR join "\t", $1, "ORFfinder", "CDS", $a, $b, ($b-$a)/100, $std, ".", "ID=" . "$1\_ORF_".("0" x (6-length($i)))."$i;NAME=$nm;"; print STDERR "\n";}' > $G.f.gff 2>$G.r.gff

abysw combin.exons $G.f.gff > $G.f.gff.tmp
abysw combin.exons $G.r.gff > $G.r.gff.tmp
cat $G.f.gff.tmp $G.r.gff.tmp > $G.gff && rm $G.f.gff $G.r.gff $G.f.gff.tmp $G.r.gff.tmp
cd ..
###########################################
echo -ne "\e[33m`date +%Y/%m/%d\ %H:%M:%S` Producting results\e[m\n"
S=`echo $G | perl -ne 'print $1 if /(\w+)/'`
[[ ! -d 01.genome ]] && mkdir 01.genome
cp genome/$G 01.genome/$S.fa
cp 00.prepare/$G.gff 01.genome/$S.gff
cd 01.genome && gffread $S.gff -g $S.fa -x $S.cds -y $S.pep && cd ..
[[ -s 01.genome/$S.cds ]] && mv genome/$G finished
DATA=`date +%Y-%m-%d--%H:%M:%S` 
echo -ne "$DATA\n" >> time/$G.time

done
