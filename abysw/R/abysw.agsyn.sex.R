#!/usr/bin/env Rscript
# File Name: /crex/proj/snic2020-2-25/nobackup/yuan/.abysw/ABYSsWrapper/R/abysw.agsyn.drawP.R
# Author: yuanfu, Yuan-SW-F, abysw@abysw.com
# Created Time: 2024-07-10 14:36:50

args = commandArgs(trailingOnly = TRUE)
ab = 0.2
if (length(args) < 1) {
	      stop("please input an agsyn file")
}

if (length(args) == 2) {
	bfile = args[2]
	    ab = as.numeric(args[2])
}

afile = args[1]
print("Reading algin file...")
nm = args[1]
pdf (paste(nm, "pdf", sep = "."), width = 9, height = 12)
#pdf (paste(nm, "pdf", sep = "."))
print("OK.")

data = read.table(afile, header = TRUE, stringsAsFactors = FALSE)
print("Start drawing picture...")
range = 200

plot(1, type = "n", xlim = c(0, range), ylim = c(0, range),
	xlab = "abysw.agsyn (www.abysw.com)", ylab = "", yaxt = "n", bty = "n", xaxt = "n")

range
n=0
data[1,2]
data[2,2]
chr_length = range
nrow(data)
ncol(data)
color = "red"
cx = rep(0,ncol(data))
cy = rep(0,ncol(data))
cs = rep(0,ncol(data))
ca = rep(0,ncol(data))

headers <- colnames(data)
for (j in 3:ncol(data)) {
#	text(data$x, data[[i]], labels = headers[i], pos = 4, col = colors[i-1], srt = 90)
	text(j + 0.5, -1, labels = headers[j], xpd = TRUE, adj = 1, cex = 1 * ab, font = 3, srt = 90)
}
for (i in 1:nrow(data)) {
   chr <- data[i,1]
   data[i,1]
   n = n+1
#   print(paste0(n, "      ", chr))
   chrtmp = chr
   chr_data <- subset(data, data$V1 == chrtmp)
   ii = floor((i-1)/4) 
#   rect(0 - 0, ii - 0, chr_length + 0, ii + 0.1, col = adjustcolor("black", alpha.f = 0.5), lwd = 0.1 * ab)
	nx = 0
	ny = 0
	ns = 0
	na = 0
   for (j in 3:ncol(chr_data)) {
		chr_data[i,j]
		if (data[i,2] == "X" && data[i,j] > 0) {
			nx = nx + 1
			color = "red" #"pink"
			cx[j] = cx[j] + 1
			polygon(c(j - 0, j + 0.5, j), c(ii , ii + 0.5, ii + 1), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		}else if (data[i,2] == "Y" && data[i,j] > 0) {
			color = "blue" #"cyan"
			ny = ny + 1
			cy[j] = cy[j] + 1
			polygon(c(j + 0.5, j + 1, j + 1), c(ii + 0.5, ii , ii + 1), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		}else if (data[i,2] == "S" && data[i,j] > 0) {
			color = "cyan"
			ns = ns + 1
			cs[j] = cs[j] + 1
			polygon(c(j + 0.5, j , j + 1), c(ii + 0.5, ii + 1, ii + 1), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		}else if (data[i,2] == "A" && data[i,j] > 0) {
			color = "grey"
			na = na + 1
			ca[j] = ca[j] + 1
			polygon(c(j , j + 1, j + 0.5), c(ii , ii , ii + 0.5), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		}
	}
	j = j + 1.2
	if (data[i,2] == "X"){
		print(paste0(ii, "      ", chr))
		chr = gsub("_", " ", chr)
		text(0 - 0.002, ii, labels = chr, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3)
		color = "red"
		polygon(c(j, j, j + (5*nx/ncol(chr_data)), j + (5*nx/ncol(chr_data))), c(ii , ii + 0.25, ii + 0.25, ii), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		text(j + 6.5, ii, labels = nx, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3, col = "red")
	}else if (data[i,2] == "Y"){
		color = "blue"
		polygon(c(j, j, j + (5*ny/ncol(chr_data)), j + (5*ny/ncol(chr_data))), c(ii + 0.25, ii + 0.5, ii + 0.5, ii + 0.25), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		text(j + 8, ii, labels = ny, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3, col = "blue")
	}else if (data[i,2] == "S"){
		color = "cyan"
		polygon(c(j, j, j + (5*ns/ncol(chr_data)), j + (5*ns/ncol(chr_data))), c(ii + 0.5, ii + 0.75, ii + 0.75, ii + 0.5), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		text(j + 9.5, ii, labels = ns, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3, col = "cyan")
	}else if (data[i,2] == "A"){
		color = "grey"
		polygon(c(j, j, j + (5*na/ncol(chr_data)), j + (5*na/ncol(chr_data))), c(ii + 0.75, ii + 1, ii + 1, ii + 0.75), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
		text(j + 11, ii, labels = na, xpd = TRUE, adj = 1, cex = 1 * ab, font = 3, col = "grey")
	}
}

print("hist")
ii = ii + 1.2
for (m in 3:ncol(chr_data)) {
	color = "red"
	mm = ii + 5*cx[m]/ncol(chr_data)
	polygon(c(m, m, m + 0.25, m + 0.25), c(ii , mm, mm, ii), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
	color = "blue"
	mm = ii + 5*cy[m]/ncol(chr_data)
	polygon(c(m + 0.25, m + 0.25, m + 0.5, m + 0.5), c(ii , mm, mm, ii), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
	color = "cyan"
	mm = ii + 5*cs[m]/ncol(chr_data)
	polygon(c(m + 0.5, m + 0.5, m + 0.75, m + 0.75), c(ii , mm, mm, ii), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
	color = "grey"
	mm = ii + 5*ca[m]/ncol(chr_data)
	polygon(c(m + 0.75, m + 0.75, m + 1, m + 1), c(ii , mm, mm, ii), col = adjustcolor(color, alpha.f = 1), border = color, lwd = 0.1 * ab, xpd = TRUE)
}
print("DONE!!!")


data <- read.table("agsx.OG.XYSA.stat.txt", header = FALSE)

x <- data$V1
y1 <- data$V2
y2 <- data$V3
y3 <- data$V4
y4 <- data$V5


pdf (paste("agsx.OG.XYSA.stat", "pdf", sep = "."), width = 9, height = 6)

x_range <- c(0, max(x))



plot(x, y1, type = "n", xlab = "abysw.agsyn (www.abysw.com)", ylab = "", ylim = range(c(0,100)))

polygon(c(x, rev(x)), c(rep(0, length(x)), rev(y1)), col = adjustcolor("purple", alpha.f = 0.8), border = NA)
polygon(c(x, rev(x)), c(rep(0, length(x)), rev(y2)), col = adjustcolor("blue", alpha.f = 0.8), border = NA)
#polygon(c(x, rev(x)), c(rep(0, length(x)), rev(y3)), col = adjustcolor("grey", alpha.f = 0.3), border = NA)

#lines(smooth.spline(x, y1, spar = 0.2), col = "purple", lwd = 2, lty = 2)
#lines(smooth.spline(x, y1, spar = 0.2), col = "purple", lwd = 2, lty = 2)
#lines(smooth.spline(x, y1, spar = 0.2), col = "purple", lwd = 2, lty = 2)

axis(1, at = seq(0, max(x), by = 10), labels = TRUE, lwd.ticks = 1)
axis(1, at = seq(5, max(x) - 5, by = 10), labels = FALSE, tcl = -0.3)

#plot(1, type = "n", xlim = c(0, range), ylim = c(0, range),
#        xlab = "abysw.agsyn (www.abysw.com)", ylab = "", yaxt = "n", bty = "n", xaxt = "n")

legend("topright", legend = c("X", "Y"), col = c("purple", "blue"), lty = 1, lwd = 2)

