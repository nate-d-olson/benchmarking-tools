#!/usr/bin/bash
#SBATCH -n 8 # number of cores
#SBATCH --mem 24g # memory pool for all cores
#SBATCH --job-name=GEM
#SBATCH --time=15:00:00
#SBATCH --partition=msalit,normal
#SBATCH --mail-type=ALL
 
echo "Running job $JOB_NAME, $JOB_ID on $HOSTNAME"

## Variables defined with job submission
# l - length
# m - mismatches
# e - edit distance

START_STIME=`date +%Y%m%dT%H%M%S`
START_TIME=`date +%s`

## Dependencies
export PATH=$PATH:/oak/stanford/groups/msalit/ndolson/GEM-binaries-Linux-x86_64-core_i3-20130406-045632/bin
BEDOPS=/oak/stanford/groups/msalit/ndolson/bedops/bin

## Variables
REF=/oak/stanford/groups/msalit/shared/genomes/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
REFID=GRCh38_no_alt
WKDIR=/oak/stanford/groups/msalit/ndolson/GRCh38_mappability/


## Indexing reference if index is not present
IDXFILE=${WKDIR}/${REFID}_gemidx
if [ -f "${IDXFILE}.gem" ]; then
    echo "${IDXFILE}.gem exists"
else 
	echo "Reference index does not exist, indexing."
	gem-indexer -i ${REF} -o ${IDXFILE} --complement emulate -T 8 
fi

gem-mappability -m ${m} -e ${e} -T 8 -I ${IDXFILE}.gem -l ${l} -o ${WKDIR}/${REFID}_gemmap_l${l}_m${m}_e${e}

gem-2-wig -I ${WKDIR}/${REFID}_gemidx.gem \
	-i ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}.mappability \
	-o ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}

sed 's/ dna//' ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}.wig > ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}_nodna.wig
sed 's/ dna//' ${WKDIR/${REFID}_gemmap__l${l}_m${m}_e${e}.sizes > ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}_nodna.sizes

${BEDOPS}/wig2bed -m 16G < ${WKDIR}/${REFID}_v37_gemmap__l${l}_m${m}_e${e}_nodna.wig > ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}.bed

awk '$5>0.9' ${WKDIR}/${REFID}_gemmap_l250_m2_e1.bed > ${WKDIR}/${REFID}_gemmap_l250_m2_e1_uniq.bed


## Not sure this is necessary
#/home/justin.zook/GEM_mappability/wigToBigWig ${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}_nodna.wig \
#	${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}_nodna.sizes \
#	${WKDIR}/${REFID}_gemmap__l${l}_m${m}_e${e}.bw

END_TIME=`date +%s`
ELAPSED_TIME=`expr $END_TIME - $START_TIME`

echo "$START_STIME  $ELAPSED_TIME" $JOB_ID $HOSTNAME 
