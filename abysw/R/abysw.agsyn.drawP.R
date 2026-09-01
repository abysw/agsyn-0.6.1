#!/usr/bin/env Rscript
# File Name: /crex/proj/snic2020-2-25/nobackup/yuan/.abysw/ABYSsWrapper/R/abysw.agsyn.drawP.R
# Author: yuanfu, Yuan-SW-F, abysw@abysw.com
# Created Time: 2024-07-10 14:36:50

args = commandArgs(trailingOnly = TRUE)

ab = 1
if (length(args) < 1) {
	      stop("please input an agsyn file")
}

if (length(args) == 2) {
	bfile = args[2]
#	    ab = as.numeric(args[2])
}

afile = args[1]


print("Reading algin file...")
nm = args[1]
pdf (paste(nm, "pdf", sep = "."), width = 9, height = 16)
print("OK.")

bed_data = read.table(afile, header = FALSE, stringsAsFactors = FALSE)
colnames(bed_data) = c("chr", "len", "start1", "end1", "start2", "end2", "id")
chromosomes = unique(bed_data$chr)

print("Start drawing picture...")
plot(1, type = "n", xlim = c(0, 1000), ylim = c(0, length(chromosomes) + 1),
	xlab = "abysw.agsyn (www.abysw.com)", ylab = "", yaxt = "n", bty = "n", xaxt = "n")

n=0
for (i in seq_along(chromosomes)) {
   chr <- chromosomes[i]
   n = n+1
   print(paste0(n, "      ", chr))
   chrtmp = chr
   chr_data <- subset(bed_data, chr == chrtmp)
   chr_length <- max(chr_data$len)
   rect(0 - 0, i - 0.03, chr_length + 0, i + 0.03, col = adjustcolor("grey", alpha.f = 100), border = "black", lwd = 1 * ab)

   for (j in 1:nrow(chr_data)) {
		start1 <- chr_data$start1[j]
		end1 <- chr_data$end1[j]
		start2 <- chr_data$start2[j]
		end2 <- chr_data$end2[j]
		id = chr_data$id[j]
		polygon(c(start1, end1, end2, start2), c(i+0.02, i+0.02, i+0.98, i+0.98), col = adjustcolor("blue", alpha.f = id * 0.01), border = "NA")
	}
	chr = gsub("_", " ", chr)
	text(0 + 180, i, labels = chr, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3)
	text(chr_length - 2, i, labels = chr_length, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3)
}
