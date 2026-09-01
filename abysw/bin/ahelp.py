#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# Author: fuyuan, Yuan-SW-F, yuanswf@163.com
# Created Time: 2022-04-12 10:05:52
# Example ahelp.py   
import sys, os, re

def c_black(word):
	return ("""\033[1;30m""" + word + """\033[0m""")
def c_red(word):
	return ("""\033[1;31m""" + word + """\033[0m""")
def c_green(word):
	return ("""\033[1;32m""" + word + """\033[0m""")
def c_yellow(word):
	return ("""\033[1;33m""" + word + """\033[0m""")
def c_blue(word):
	return ("""\033[1;34m""" + word + """\033[0m""")
def c_magenta(word):
	return ("""\033[1;35m""" + word + """\033[0m""")
def c_cyan(word):
	return ("""\033[1;36m""" + word + """\033[0m""")
def c_white(word):
	return ("""\033[1;37m""" + word + """\033[0m""")
def c_gw(word):
    return ("""\033[42;37m""" + word + """\033[0m""")
def c_rw(word):
    return ("""\033[41;37m""" + word + """\033[0m""")
def c_wg(word):
    return ("""\033[47;32m""" + word + """\033[0m""")
def c_bw(word):
    return ("""\033[44;37m""" + word + """\033[0m""")
def c_mw(word):
    return ("""\033[45;37m""" + word + """\033[0m""")
def c_cw(word):
    return ("""\033[46;37m""" + word + """\033[0m""")

def a_color(arg):
	num = 0
	for i in arg:
		num = num + 1
		if num%2 == 1:
			print (c_gw(i), end = '')
		else:
			print (c_wg(i), end = '')

def a_color2(arg):
    num = 0
    for i in arg:
        num = num + 1
        if num%2 == 1:
            print (c_rw(i), end = '')
        else:
            print (c_rw(i), end = '')

def a_split(string):
	string = string
	strings = []
	num = 0
	line = string.split('*')
	for j in (line[1:]):
		substring = line[0][num:num+int(j)]
		strings.append(substring)
		num += int(j)
	strings.append(line[0][num:])
	return(strings)

def a_head(string):
	string = string
	re_time = re.search("ABYSsWrapper version is (\S+) (\d\d\d\d)(\d\d)(\d\d)", string)
	i = ""
	j = ""
	if re_time:
		i = re_time.group(1)
		j = "-".join([re_time.group(2), re_time.group(3), re_time.group(4)])

	list =(
'               ______  _      _    ____  _       _ ',
'      /\      ||————\\\\ \\\\    //   //——— ||      || ',
'     //\\\\     ||    //  \\\\  //   //     ||      || ',
'    //__\\\\    ||___//    \\\\//    \\\\     ||  /\  || ',
'   //————\\\\   ||————\\\\    ||      \\\\    || //\\\\ || ',   
'  //      \\\\  ||    //    ||  ____//    ||//  \\\\|| ',
' //        \\\\_||___//     ||  ————^     |/      \| ' ,
'___________________________________________________',
)
#    list =(
#'                 _      _      _                   ',
#'        /\      ||      \\\\    //                   ',
#'       //\\\\     ||       \\\\  //                    ',
#'      //__\\\\    ||___     \\\\//     __           _  ',
#'     //————\\\\   ||———\\\\    ||     //   \\\\  /\  //  ',
#'    //      \\\\  ||   //    ||     \\\\    \\\\//\\\\//   ',
#'   //        \\\\_||__//     ||   __//     \/  \/    ',
#'___________________________________________________',
#)
	for ii in list:
		string = a_split(ii)
		a_color2(string)
		print ('')


	list =(
"                                                   ",
"        ABYSsWrapper (abysw) Version "+i+"         *11*6*5*5",
"        Author: Yuan-SW-F, abysw@abysw.com         *12*3*6*4",
"        A Blessing from Yuan to SunWenjing         *12*3*5*3",
"        Example: abysw command option              *12*3*4*3",
"        Updating Time: " + j +  "                  *12*8",
"        Created Time: 2020-11-09                   *12*5",
"        Python version: python3                    *12*8",
"       For more information please browser:        *12*3*3*5",
"           https://www.cnblogs.com/abysw           *12*3*6*3",
"           https://github.com/abysw                *12*3*7*3",
"           https://gitee.com/abysw                 *12*3*8*3",
"           https://abysw.com                       *12*3*9*3",
"           https://abysw.cn                        *12*3*10*3",
"           WeChat Official Account: swxxfxxx       *12*3*11*4",
"     TO MY KING king To My King king TO MY KING    *11*5*11*4",
"                                                   ",
)
	for i in list:
		string = a_split(i)
		a_color(string)
		print ()
	return""

adict = {}
def ahash(tdict):
	cmd_ = "\t-d 1 for no files"
	for i in tdict.keys():
		cmd_ = "\t" + i + " " + ("\033[0m.\033[1;37m" * (35 - len(i))) + " * abysw " + i + " " + adict[i].replace("##", "\n\t " + (" " * 36) + "\033[1;30m ")
		cmd_ = cmd_.replace("#", "\033[1;30m#")
		print (c_white(cmd_))
	print ()

def ahash2(akey):
	cmd_ = "\t-d 1 for no files"
	if akey in adict.keys():
		cmd_ = "\t" + akey + " " + ("\033[0m.\033[1;37m" * (35 - len(akey))) + " * abysw " + akey + " " + adict[akey].replace("#", "\n\t " + (" " * 36) + "\033[0m ")
	return(c_white(cmd_))

#############################################################################################
def standin():
	print (c_green("mread file from standin"))
	tmp_ab = """	cat file | abysw lst                 * change space to line or line to space
	cat file | abysw matrix              * statistics
	cat file.gff | abysw togff           * cat *gff | abysw to gff [mRNA]
	cat file.bed | abysw sumbed          * statistics bed file
	cat file.bed | abysw sumgff          * statistics gff file
	cat file | s21 -n n                  * statistics number of n column
	"""
	print (c_white(tmp_ab))
	tmp_ab = ""

#############################################################################################
# genome =============================================
d_asm = {
	"a.rna":    "a_trinity_aRNA_ID genome_fasta genome_gff",
	"a.meta":   "reference.fa query.fa",
	"augustus": "a_maker_a",
	"3dDNA":    "a_hicpro2_agenome",
	"cdhit":    "sequence identity",
	"close":    "reference sequence",
#	c_green("annotation"):		"",
	"edta":     "a_EDTA_agenome.fa",
	"edta.lai":	"genome.fa",
	"hifiasm":  "genome.fa kmer",
	"pasa":     "database_name genome gff transcript",
	"snap":     "snap [ctl, next, ]",
	"gmark":	"genome_fasta",
	"trinity":  "a_trinity_a",
	"ipr":		"",
	"pre.psg":	"genome.fa genome.mask.fa genome.gff protein.fa ",
}
adict.update(d_asm)

def genome():
	print (c_green("genome Wrapper: assembly (a.) && annotation (a.)"))
	ahash(d_asm)

def assembly():
	print (c_green("assembly (a.) && annotation (a.)"))
	ahash(d_asm)

# blog ==============================================
adict2 = {
	"up":       "push updated blog to github",
	"path":     "get the blog path",
	"list":     "get all blog list",
	"tags":     "get all blog tags",
	"categories": "get all blog categories",
	"[others]": "write a new or rewrite an old blog",
}
adict.update(adict2)
d_blog = adict2

def blog():
	print (c_green("for write blog"))
	ahash(d_blog)

# change_format ======================================
d_cfmt = {
	"c.gff":    "species.gff # change gff file id",
	"c.fa":     "species.fa # change fasta file id",
	"fq2fa":    "file.fq > file.fa # change fastq to fasta",
	"c.ann":    "maker.all.gff species # init annotation result",
	"gfa2fa":	"gfa2fa hifiasm.gfa > fa",
	"fa2phy":   "file.fa > file.phy # format swich: MSA fasta to phylip",
	"phy2fa":   "file.phy > file.fa # format swich: phylip to fasta",
	"wig2bed":  "file.wig > file.bed # format swich: wig to bed",
	"spgff":    "file.gff # split total gff file to each choromosome",
	"cds4gff":  "file.gff file.cds # get cds from gff",
	"bed4gene": "gene.list bed 1000000 # get 1Mb bed from gene list",
	"flank4gene": "list file.bed int int ## eg: abyss flank4gene gene.list *.bed<file> upstream<int> downstream<int>, ## \"not\" means exclude gene regin. eg: abyss flank4gene gene.list *.bed upstream",
	"linkfa":   "sp.list fasta.file # link msa fasta files to one phylip file",
	"maf2bed":  "msa.maf # extract reference locs",
	"gb2gff":   "*.gb # genebank to gff and genome",
	"hash":		"file1 file2 # select information from file2 by file1",
	"paste":	"file1 file2 [head] # paste file1 and file2, [head : include head]",
	"merge":	"file1 [file2...] # extract the first occurrence element from all files",
}
adict.update(d_cfmt)

def change_format():
	print (c_green("change (c.) format"))
	ahash(d_cfmt)

# comparative genomics ==================================
d_compare = {
	"blast et al.": "",
	"tree":		"msa.file # build gene tree",
	"callcbs":	"file.msa # comparative genomics of non-coding sequence ## Filter out sequences with nt < 5bp and query_len/reference_len < 0.5, ## Filter out blocks with fewer than 1 rows.",
	"unqid":	"multipe.file # uniq id for different element",
	"domain":	"PFXXXX # download domain.hmm",
	"hmm":		" hmmsearch",
	"blastp":	"query db [1e-5]",
	"blastn":   "query db [1e-5]",
	"gmap":		"species sampleID",
	"orthofinder":	"orthofinder -t 250 -a 250 -d -f ./ -S diamond",
	"blastnr":	"sequence evalue",
	"bwa":		"reference.fa query.fa",
	"minimap2":	"reference.fa query.fa",
	"minimap": "reference.fa query.fa",
}
adict.update(d_compare)

def compare():
	print (c_green("comparative genomics"))
	ahash(d_compare)

# draw (d.) picture ======================================
d_draw = {
	"gene_density": "genome.fa gene.gff repeat.gff window",
}
adict.update(d_draw)

def draw():
	print (c_green("draw (d.) picture"))
	ahash(d_draw)

# evalute (e.) && extract (ex.) =========================
d_evalute = {
	"e.lai": "",
	"busco": "",
	}
adict.update(d_evalute)

d_extract = {
	"ex.fa":    "",
	"getcds":   "",
	"getfa":    "gene.list file.fa # use genelist extract sequence from fasta file",
}
adict.update(d_extract)

def evalute():
	print (c_green("evalute (e.)"))
	ahash(d_evalute)
	print (c_green("extract (ex.)"))
	ahash(d_extract)

# filter (f.) ==============================================
d_filter = {
	"f.fa":     "file.fa<file> length #filter sequence length less than length<int> from fasta file",
	"f.bgi":    "BGI_R1.fastq.gz #filter BGIseq reads",
	"f.hic":    "HIC_R1.fastq.gz #filter BERseq reads",
	"f.iso":    "ann.gff [suffix] #filter shorter isoform",
	"f.valid":  "#filter bad HIC reads",
	"end":      "#filter protien end [*/.]",
}
adict.update(d_filter)
def filter():
	print (c_green("filter (f.)"))
	ahash(d_filter)

def manual():
	text = [
	c_green("manual (m.)"),
	""]
	print (("\n".join(text)))
	os.system("cat " + sys.path[0] + "/../root/mount")

# syntenic (syn.) anaysis ===================================
d_syntenic = {
	"syn.jcvi": "species1.cds specise2.cds",
	"syn.ngs":  "syntenic.NGS [-o out -s suffix ] sp1 sp2 ... # -o output # -s [anchors .last.filtered .lifted.anchors]",
	"syn.plot":	"[-o out -s suffix -r pep ] sp1 sp2 ... # -o output # -s [anchors .last.filtered .lifted.anchors]"
}
adict.update(d_syntenic)
def syntenic():
	print (c_green("syntenic (syn.) anaysis"))
	ahash(d_syntenic)

# statistics (s.) =========================================
d_statistics = {
	"s.busco":  " ",
	"s.gene":   " ",
	"miss":     "file1 file2 # find different lines of file2 from file1",
	"sum":      "opt file # beta opt[tophat, ]",
	"sort":		"sort.list file # sort file by list",
	"sumbed":	"cat file.bed |abysw sumbed              # statistics bed file",
	"sumgff":	"cat file.gff |abysw sumgff              # statistics gff file",

}
adict.update(d_statistics)
def statistics():
	print (c_green("statistics (s.)"))
	ahash(d_statistics)

# task ===================================================
d_task = {
	"nohup":    "# nohup shell",
	"sh":       "sh number<int> # split shell number",
	"qs":       "int int files # qsub works",
	"chd":      "dir [del] # alias directory, del delete alias",
	"tar":      "files",
} 
adict.update(d_task)
def task():
	print (c_green("make task start"))
	ahash(d_task)

# resequence
d_resequence = {
	"gatk":		"reference fastq outprefix # step 1, filter reads, mapping, marked, mpileup, BQSR, callSNPs, jointcall, SNPfilter",
	"joint":		"ref *.g.vcf.gz			# step 1.6, joint calling",
	"filterSNP":	"*raw.vcf				# step 1.7, SNPs filter",
	"splitgvcf":	"*gvcf				# step 1.6.1, split *.g.vcf by chromosomes",
	"snpeff":		"refence_name *.vcf			# step 2, SNPs and Indels annotation",
	"pca":			"*.vcf					# step 3, pca and structure",
	"ld":			"*vcf group.list				# step 4, LD decay",
	"gwas":			"bfile					# step 5, GWAS",
	"add":			"file1 file2 key target key # step 5.1, merge information. ## Select target from file1 by key, and add the target info to file2",
	"fam":			"fam.file chara.file line		# step 5.2, prepare fam files",
	"dlssr":		"SRR_ID					# step 0, download reads",
	"pcagroup":		"chara.file pcatmp.eigenvec > pcatmp.eigenvec.txt",
	"structure":	"prefix.fam sort.list *Q",
	"drawpca":		"pcatmp.eigenvec.txt",
	"reseqs":		"",
}
adict.update(d_resequence)
def resequence():
	print (c_green("resequence"))
	ahash(d_resequence)

#################################################################################
# genefamily
d_genefamily = {
	"orthofinder":	"",
	"lowcov":	"genecountfile coverage[5]",
	"lcgene":	"loc_coverage.file ref.sp sp[Artha] [all.cds] [../Orthogroup_Sequences] [sp.list]",
	"bestm8":	"file.m8",
	"rbh":		"rbh f.m8 r.m8",
	"kaks":		"sp1 sp2",
	"ksplot":	"sp1 sp2",
	"ttest":	"clade orthofinder.csv",
	"ttest2":	"clade orthofinder.csv line",
	"veen.of":	"class orthofinder.csv",
	"linkrbh":	"species sp.list RBH.dir",
	"f.rbh":	"rbh.matrix cutoff[0.66]",
	"getseq.rbh":	"extract sequence from protein sequence file by rbhmatrixfile",
	"go.enrich":	"emapper genelist1[,genelist2,...] [exp]",
}

adict.update(d_genefamily)
def genefamily():
	print (c_green("genefamily"))
	ahash(d_genefamily)

#################################################################################
#################################################################################
# unclassed ===============================================
d_unclassed = {
	"cds2aa":	"",
	"n50":		"",
}

d_more = {
	"sample":	"sample r, pca, deninsity, and so on",
	"<directory>":	" for more script, [common perl python R shell]",
	"more":		"list more information",
	"list":		"list all tools",
	"backup":	"please input version number",
}
adict.update(d_unclassed)
adict.update(d_more)
def unclass():
	print (c_green("unclassed script"))
	ahash(d_unclassed)
	print (c_green("some useful script samples, if you choice this, the scripts will display on your work screen"))
	ahash(d_more)

def shell_(cmd_id):
	abyss_path = sys.path[0]
	_shell_ = os.popen('ls ' + abyss_path + '/../*/abysw.' + cmd_id + '{.pl,.py,.sh,.R,.shell.pl}  2> /dev/null | tail -n 1')
	_shell_ = _shell_.readline()
	_shell_ = _shell_.strip()
	return _shell_

def help(akey):
	print (c_green("Usage Help:"))
	if akey in adict.keys():
		re_adict = re.search("a_(\S+)_a", adict[akey])
		if re_adict:
			print (c_blue("\tplease use '" + re_adict.group(1) + "' conda enviroment"))
			adict[akey] = adict[akey].replace("a_" + re_adict.group(1) + "_a", '')
		cmd_ = "\t" + akey + " " + ("\033[0m.\033[1;37m" * (35 - len(akey))) + " * abysw " + akey + " " + adict[akey].replace("#", "\n\t " + (" " * 36) + "\033[0m ")
		print (c_white(cmd_))
	else:
		cmd_id = sys.argv[1]
		cmd_cmd = shell_(cmd_id)
		if not cmd_cmd:
			cmd_id = re.sub('\.', '/', cmd_id)
			cmd_cmd = shell_(cmd_id)
		if not cmd_cmd:
			cmd_id = re.sub('\/', '/abysw.', cmd_id)
			cmd_cmd = shell_(cmd_id)
#		print (cmd_id)
		if cmd_cmd:
			re_cmd = re.search('ABYSsWrapper/bin/\.\./([^\/\s]+)', cmd_cmd)
			if re_cmd:
				print (c_blue("this fuction is only beta version, but you can try to use it, please not panic!"))
				print (c_green("User guide:"))
				print (ahash2(cmd_id))
		else:
			print (c_red("no \"" + sys.argv[1] + "\" function, please type `abysw -h` for more help"))
			print (c_blue("this fuction is not online, please feedback to the author to add new features!"))


def more():
	text = []
	text.append(c_cyan("############################################################################"))
	text.append(c_cyan("####################*****                          *****####################"))
	text.append(c_cyan("##########*****                    MORE                      *****##########"))
	text.append(c_cyan("####################*****                          *****####################"))
	text.append(c_cyan("############################################################################"))
	text.append("")
	text.append(c_yellow(">>> BUSCO        "))
	text.append("\t" + '''run_BUSCO.py -i  -o bus_species_geno__embryophyta -l /busco_dabase_path/embryophyta_odb9 -m geno -c 30 -f
''')
	text.append(c_yellow(">>> Assembly     "))
	text.append("\t" + '''SparseAssebmler g $skipk k $kmer LD 0 $gsize NodeCovTh 2 EdgeCovTh 1 $contig
	SSPACE_Standard_v3.0.pl -l library.txt -s $fasta -x 0 -m 32 -o 20 -z 0 -k 8 -a 0.7 -n 15 -T 12 -b assembly -p 1
''')
	text.append(c_yellow(">>> Comparative     "))
	text.append("\t" + '''hmmbuild --amino out mutilp-aligment; hmmsearch out .fa>test.out        
	makeblastdb -in $i -dbtype prot; blastp -query $j -db $i -outfmt 6 -evalue 1e-30 -num_threads 16 -out $R-$M.m8
''')
	text.append(c_yellow(">>> SV          "))
	text.append("\t" + '''conda install -c bioconda lumpy-sv; conda install -c bioconda samblaster
''')
	text.append(c_yellow(">>> install by conda"))
	text.append("\t" + '''conda install -c genomedk treepl
''')
	text.append(c_yellow(">>> Website   "))
	text.append("\t" + '''UCSC:
		http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/
	cd-hit:
		https://github.com/weizhongli/cdhit/releases/download/V4.6.7/cd-hit-v4.6.7-2017-0501-Linux-binary.tar.gz
	SOAPdenovo:
		https://sourceforge.net/projects/soapdenovo2
	MCL: 
		http://www.micans.org/mcl/src/mcl-latest.tar.gz
	orthomcl:
		http://orthomcl.org/common/downloads/software/v2.0/orthomclSoftware-v2.0.9.tar.gz
	conda:
		https://docs.conda.io/en/latest/miniconda.html
		https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh 
		https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	blast db:ftp://ftp.ncbi.nlm.nih.gov/blast/db/{nt,nr}*tar.gz
	download SRA:
		wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos2/sra-pub-run-9/SRR***/SRR***
		fastq-dump --split-files SRR***
		~/.aspera/connect/bin/ascp -QT -l 300m -P33001 -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR*/SRR***/SRR***.fastq.gz ./
		prefetch -O output --option-file SRR_Acc_List.txt
		fastq-dump SRR***.sra --split-3 --gzip --defline-qual '+'  -A filename -O outdir
	
###############################################################################	
	other download links:
	wget https://downloads.pacbcloud.com/public/software/installers/smrtlink_8.0.0.80529.zip  --no-check-certificate 
''')
	text.append(''' ''')
	text.append("--------------------------- to be continued -------------------------")
	text.append("")

	return(("\n".join(text)))

def alog():
	print (c_cyan("20220701：在0.2.7版本中，删除了ahead模块"))
	print (c_cyan("20220705: 对说明文档重新进行了描述"))
	print (c_cyan("20220715: 本次将更新基因家族相关模块"))
	print (c_cyan("20221026: 本次新增目录分类形式脚本"))
	print (c_cyan("20221114: 本次常规更新，并删除冗余注释"))
	print (c_cyan("20221201: 本次更新注释信息，使之更简洁"))
	print (c_cyan("20230203: 本次更新blastp和rbh的使用习惯"))
	print (c_magenta("20230301: I updated some using habit in this version."))
	print (c_magenta("20230312: I will change same usage mode more convenient to suit the projects in Lund University."))

