#!/usr/bin/bash

## Extracting chromosomes 1-22, X, and Y
grep -e "$(printf '^chr[0-9XY]\t')" -e "$(printf '^chr[12][0-9]\t')" human.hg38.genome \
	> tmp

## Sorting
sed 's/^chr//;s/^X/23/;s/^Y/24/;s/^M/25/' tmp |\
	 sort -k1,1n -k2,2n |\
	 sed 's/^23/X/;s/^24/Y/;s/^25/M/;s/^/chr/'  \
	> human.hg38.chroms.only.genome

rm tmp 

## Generating BAM
awk -F "\t" '{print $1,"\t1\t", $2}' human.hg38.chroms.only.genome \
	> human.hg38.chroms.only.genome.bed
