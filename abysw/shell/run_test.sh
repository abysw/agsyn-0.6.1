#!/bin/bash
# File Name: run_agss.sh
# Author  : yuanfu1, Yuan-SW-F, abysw@abysw.com
# Created Time: 2025-06-18 21:33:27
# Please find more information in abysw.com or github(abysw)

#reference species
R=Gallus_gallus
#species name list
S=species.lst
#path of species infomation
P=~/agsyn/ref/$R


for i in `cat $S | grep -v $R`;do
    abysw agsyn.sort $R $i # sort chromosome order
    abysw agsyn.syn $R $i  # obtain .agsyn files
done

cat $S | perl -ne 'chomp; print "$_.agsyn "' | perl -ne 'chomp; `cat $_ > Draw.agsyn`' && mv Draw.agsyn $S.agsyn
abysw agsyn.draw $S.agsyn # draw syntenic

