#!/usr/bin/bash
#SBATCH -n 8 # number of cores
#SBATCH --mem 24g # memory pool for all cores
#SBATCH --job-name=GEM
#SBATCH --time=10:00:00
#SBATCH --partition=msalit,normal
#SBATCH --mail-type=ALL
 
echo "Running job $JOB_NAME, $JOB_ID on $HOSTNAME"



START_STIME=`date +%Y%m%dT%H%M%S`
START_TIME=`date +%s`

## Dependencies
GEM=/oak/stanford/groups/msalit/ndolson/GEM-binaries-Linux-x86_64-core_i3-20130406-045632/bin
BEDOPS=/oak/stanford/groups/msalit/ndolson/bedops/bin

## Variables
REF=/oak/stanford/groups/msalit/shared/genomes/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
REFID=GRCh38_no_alt
WKDIR=/oak/stanford/groups/msalit/ndolson/GRCh38_mappability/

${GEM}/gem-indexer -i ${REF} -o ${WKDIR}/${REFID}_gemidx --complement emulate -T 8 

${GEM}/gem-mappability -m 2 -e 1 -T 4 -I ${WKDIR}/${REFID}_gemidx.gem -l 250 -o ${WKDIR}/${REFID}_gemmap_l250_m2_e1

${GEM}/gem-2-wig -I ${WKDIR}/${REFID}_gemidx.gem \
	-i ${WKDIR}/${REFID}_gemmap_l250_m2_e1.mappability \
	-o ${WKDIR}/${REFID}_gemmap_l250_m2_e1

sed 's/ dna//' ${WKDIR}/${REFID}_gemmap_l250_m2_e1.wig > ${WKDIR}/${REFID}_gemmap_l250_m2_e1_nodna.wig
sed 's/ dna//' ${WKDIR/${REFID}_gemmap_l250_m2_e1.sizes > ${WKDIR}/${REFID}_gemmap_l250_m2_e1_nodna.sizes

${BEDOPS}/wig2bed -m 16G < ${WKDIR}/${REFID}_v37_gemmap_l250_m2_e1_nodna.wig > ${WKDIR}/${REFID}_gemmap_l250_m2_e1.bed

awk '$5>0.9' ${WKDIR}/${REFID}_gemmap_l250_m2_e1.bed > ${WKDIR}/${REFID}_gemmap_l250_m2_e1_uniq.bed


## Not sure this is necessary
#/home/justin.zook/GEM_mappability/wigToBigWig ${WKDIR}/${REFID}_gemmap_l250_m2_e1_nodna.wig \
#	${WKDIR}/${REFID}_gemmap_l250_m2_e1_nodna.sizes \
#	${WKDIR}/${REFID}_gemmap_l250_m2_e1.bw

END_TIME=`date +%s`
ELAPSED_TIME=`expr $END_TIME - $START_TIME`

echo "$START_STIME  $ELAPSED_TIME" $JOB_ID $HOSTNAME 
