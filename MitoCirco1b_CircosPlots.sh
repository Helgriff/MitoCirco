#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ############################################
module load $6
##########################################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
SCRIPTS_DIR=$3
Q=$4
TYPE=$5
INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
COV_DIR="${INDIR}/coverage"
DUP_FREE_BAM_DIR="${INDIR}/dup_free_bam"
VARSCAN_OUT_DIR="${INDIR}/varscan2"
CIRCOS_OUT_DIR="${INDIR}/circos"
MSK_OUT_DIR="${INDIR}/mitoseek"

echo $'\n'mkdir $CIRCOS_OUT_DIR
if [ ! -d $CIRCOS_OUT_DIR ]
then
	mkdir $CIRCOS_OUT_DIR
else
	echo "$CIRCOS_OUT_DIR exists"   
fi

SAM_FILE1hg38b="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_hg38.sam"
SAM_FILE1rCRSb="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_rCRS.sam"
SAM_FILE1hg38bplus="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_hg38plus.sam"
DUP_FREE_BAMhg38="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_hg38.bam"
DUP_FREE_BAMrCRS="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_rCRS.bam"
DUP_FREE_BAMhg38plus="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_hg38plus.bam"

if [ ! -f $SAM_FILE1hg38b ]
then
echo $'\n'"["`date`"]: Recreate Sam files."
samtools view ${DUP_FREE_BAMhg38} >${SAM_FILE1hg38b}
samtools view ${DUP_FREE_BAMrCRS} >${SAM_FILE1rCRSb}
samtools view ${DUP_FREE_BAMhg38plus} >${SAM_FILE1hg38bplus}
else
	echo "Found Sam file"
fi

############### Circos Plot ##################################################
CIRC_CONFILE="${CIRCOS_OUT_DIR}/circos.conf"
CIRC_CONFILE2="${CIRCOS_OUT_DIR}/circos2.conf"
# perl #script(s) to create circos config, link and data input files from coverage and varscan outputs, plus comparison between hg38 and rCRS sam files
perl "${SCRIPTS_DIR}/PerlScripts/Format_mtDNAPileups_into_oneFile.pl" ${COV_DIR} ${CIRCOS_OUT_DIR} ${SAMPLE_ID} ${TYPE}
perl "${SCRIPTS_DIR}/PerlScripts/Format_mtDNA_sam_links_into_oneFile.pl" ${DUP_FREE_BAM_DIR} ${CIRCOS_OUT_DIR} ${SAMPLE_ID} ${Q}
perl "${SCRIPTS_DIR}/PerlScripts/Format_mtDNAvcfs_into_oneFile.pl" ${VARSCAN_OUT_DIR} ${CIRCOS_OUT_DIR} ${SAMPLE_ID}
perl "${SCRIPTS_DIR}/PerlScripts/Format_mtDNA_MSKhets_into_oneFile.pl" ${MSK_OUT_DIR} ${CIRCOS_OUT_DIR} ${SAMPLE_ID}
perl "${SCRIPTS_DIR}/PerlScripts/Make_circos_conf_file.pl" ${CIRCOS_OUT_DIR} ${SAMPLE_ID} ${SCRIPTS_DIR}
perl "${SCRIPTS_DIR}/PerlScripts/Make_circos_conf_file2.pl" ${CIRCOS_OUT_DIR} ${SAMPLE_ID} ${SCRIPTS_DIR}
## run circos
circos -conf ${CIRC_CONFILE} -dir ${CIRCOS_OUT_DIR} -file "${SAMPLE_ID}_links" #link mtDNA and nuclear, read depth and variants
circos -conf ${CIRC_CONFILE2} -dir ${CIRCOS_OUT_DIR} -file "${SAMPLE_ID}_mtDNAdepth" #comparing 2x mtDNA depths+vars
##############################################################################

##cleaning
rm ${SAM_FILE1hg38b} ${SAM_FILE1rCRSb} ${SAM_FILE1hg38bplus}

echo $'\n'"["`date`"]: MitoCirco1b_CircosPlots is Complete!!"

# runtime calculation
res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
echo "exit status $?"
