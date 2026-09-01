#!/bin/bash
# File Name: run_agsyn_agsx.sh
# Author  : yuanfu1, Yuan-SW-F, abysw@abysw.com
# Created Time: 2025-06-19 18:46:07
# Please find more information in abysw.com or github(abysw)

perl abysw.agsyn.agsx.og.pl -x 0.95 -y 15 Orthogroups.tsv
Rscript abysw.agsyn.agsx.R agsx.OG.XYSA.top.agsx
perl abysw.agsyn.agsx.func.pl
