#!/usr/bin/env Rscript
# File Name: /crex/proj/snic2020-2-25/nobackup/yuan/.abysw/ABYSsWrapper/R/abysw.agsynR.R
# Author: yuanfu, Yuan-SW-F, abysw@abysw.com
# Created Time: 2024-05-27 10:08:18
# Tool in agsyn.0.6.1 (abysw.0.7.6)

args = commandArgs(trailingOnly = TRUE)
ab = 1
if (length(args) < 1) {
	  stop("please input an agsyn file")
}

if (length(args) >= 2) {
	ab = as.numeric(args[2])
}
abw = 9
if (length(args) >= 3) {
	abw = as.numeric(args[3])
}

afile = args[1]

print("Reading agsyn file...")
nm = args[1]
pdf (paste(nm, "pdf", sep = "."), width = abw, height = 16)
print("OK.")

bed_data = read.table(afile, header = FALSE, stringsAsFactors = FALSE)
colnames(bed_data) = c("chr", "start", "end", "name", "score", "strand", "color")
chromosomes = unique(bed_data$chr)

print("Start drawing picture...")
plot(1, type = "n", xlim = c(0, 1), ylim = c(0, length(chromosomes) + 1), 
     xlab = "abysw.agsyn (www.abysw.com)", ylab = "", yaxt = "n", bty = "n", xaxt = "n")
#plot(1, type = "n", xlim = c(min(bed_data$start), max(bed_data$end)), ylim = c(0, length(chromosomes) + 1), 

n=0
for (i in seq_along(chromosomes)) {
  chr <- chromosomes[i]
  n = n+1
  print(paste0(n, "      ", chr))
  chrtmp = chr
  chr_data <- subset(bed_data, chr == chrtmp)
  chr_length <- max(chr_data$end)
#  chr_length = chr_data$end[1]
#  print(chr_data$end[1])
  
  for (j in 1:nrow(chr_data)) {
    start <- chr_data$start[j] / chr_length
    end <- chr_data$end[j] / chr_length
    color <- chr_data$color[j]
    name <- chr_data$name[j]
    note <- chr_data$strand[j]
	if (length(note) >= 8){
		print(length(note))
		note = ""
	}
    if (name == "chr") {
		rect(start - 0.0001, i - 0.3, end + 0.0001, i + 0.3, col = adjustcolor(color, alpha.f = 0), border = color, lwd = 0.5 * ab)
		#rect(start - 1000000/chr_length, i - 0.2, end + 1000000/chr_length, i + 0.3, col = adjustcolor(color, alpha.f = 0), border = color, lwd = 1)
		text(end + 0.003, i, labels = note, cex = 0.6 * ab)
    } else if (name == "act") {
		rect(start, i - 0.3, end, i - 0, col = adjustcolor(color, alpha.f = 1), border = NA)
		text((start + end) / 2, i - 0.15, labels = note, col = "white", cex = 0.4 * ab)
    } else if (name == "sex") {
		if (note == "elav"){
			color = "blue"
			rect(start, i + 0.32, end, i + 0.50, col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1)
			symbols((start + end)/2, i + 0.52, circles = 0.005 * ab * 9 / abw, inches = FALSE, add = TRUE, bg = color, lwd = 0.1 * ab)
		}else{
			rect(start, i + 0.32, end, i + 0.45, col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1)	#old
			polygon(c((start + end)/2 - 0.002 * 9 / abw, (start + end)/2 + 0.002 * 9 / abw, (start + end)/2), c(i + 0.45, i + 0.45, i + 0.32), col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1 * ab)	#old
		}
    } else if (name == "sexA") {
		rect(start, i + 0.32, end, i + 0.45, col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.5)
		symbols((start + end)/2 + 0.0015, i + 0.45, circles = 0.002, inches = FALSE, add = TRUE, bg = color, lwd = 0.1 * ab)
#		polygon(c((start + end)/2 - 0.002, (start + end)/2 + 0.002, (start + end)/2), c(i + 0.45, i + 0.45, i + 0.32), col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1 * ab)
	} else if (name == "sexB") {
		rect(start, i + 0.32, end, i + 0.45, col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.05)
		symbols((start + end)/2 - 0.0015, i + 0.45, circles = 0.002, inches = FALSE, add = TRUE, bg = color, lwd = 0.1 * ab)
#		polygon(c((start + end)/2 - 0.002, (start + end)/2 + 0.002, (start + end)/2), c(i + 0.45, i + 0.45, i + 0.32), col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1 * ab)
	} else if (name == "contig") {
		polygon(c((start + end)/2 - 0.002, (start + end)/2 + 0.002, (start + end)/2), c(i - 0.5, i - 0.5, i - 0.32), col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1 * ab)
	} else {
#			polygon(c((start + end)/2 - 0.002, (start + end)/2 + 0.002, (start + end)/2), c(i + 0.45, i + 0.45, i + 0.32), col = adjustcolor(color, alpha.f = 0.33), border = color, lwd = 0.1 * ab)
		rect(start, i - 0, end, i + 0.3, col = adjustcolor(color, alpha.f = 0.5), border = NA)
	}
}	
	chr = gsub("_", " ", chr)
	text(0 - 0.002, i, labels = chr, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3)
#  text(-max(bed_data$end) * 0.02, i, labels = chr, xpd = TRUE, adj = 1)
}
