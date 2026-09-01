#!/bin/bash
# File Name: run.sh
# Author  : yuanfu1, Yuan-SW-F, abysw@abysw.com
# Created Time: 2025-06-19 18:04:19
# Please find more information in abysw.com or github(abysw)

wget https://abysw.com/agsyn/agsyn/genome.tar.gz
tar zxvf genome.tar.gz
gunzip protein/*gz

sh abysw.agsyn.sh run
