#! /bin/bash

#*********************************************************************************************************************************************************##
## Script to Launch Variant Calling accross multiple bam files, creating Multi-Sample VCF Files, combining hg38 and hg38plus files and Annotation by Annovar																##
#*********************************************************************************************************************************************************##

##N.B. Bam files moved (mv) into directory (${SAMPLE_PATH}/${SAMPLE_ID}/) and $BAMLIST created (ls ${SAMPLE_PATH}/${SAMPLE_ID}/*${REF_BUILD}.bam > $BAMLIST)
##Bam lists restricted to groups of < approx. 800 samples ($GROUP_$BAMLIST) ... otherwise jobs now fail on cluster, memory restrictions!?!

SAMPLE_ID="4771_hg38"
SAMPLE_ID2="4771_hg38plus"

INALL=(PFC67 PFC8 PFC9 NDCN12 NDCN34 NDCN56 NDCN789 WTCCC125 WTCCC126 WTCCC127) #Array containing bamlist group names

SAMPLE_PATH="/home/BAMs/4771"
SCRIPT_PATH="/home/Scripts"
REF_BUILD="hg38"
REF_FILE="/home/hg38.fa"
REF_BUILD2="hg38plus"
REF_FILE2="/home/hg38_rCRS8330.fa"
Q=25
MaxD=200
IntGENES="/home/rCRS/hg38_MitochondrialGenes.txt"
IHMAF="/home/InHouse_FastuniqBWAFreebayesPipe_Variants_MAFs_281files.txt.gz"
BMQ="all.q,bigmem.q"
LMEM="h_vmem=15G"
EMAIL="email@base.com"
SMT13="apps/samtools/1.3"
PRL="apps/perl/5.18.2"
VTL="apps/vcftools/0.1.12b"
ANV="/home/annovar_jan2016"

#1# Call Variants at every chrM position using Samtools in batches of < ~800 sampleIDs (now fails with larger sample numbers!!)
JOBHOLD="NONE"
for GROUP in "${INALL[@]}"; do
BAMLIST="${SAMPLE_PATH}/${GROUP}_${SAMPLE_ID}_bams.txt"
BAMLIST2="${SAMPLE_PATH}/${GROUP}_${SAMPLE_ID2}_bams.txt"
JOB_ID1="v_${GROUP}_${SAMPLE_ID}"
JOB_ID1b="v_${GROUP}_${SAMPLE_ID}"
arr13=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "$MaxD" "${REF_BUILD}" "${REF_FILE}" "${BAMLIST}" "$SMT13" "$GROUP")
arr14=("${SAMPLE_ID2}" "${SAMPLE_PATH}" "$Q" "$MaxD" "${REF_BUILD2}" "${REF_FILE2}" "${BAMLIST2}" "$SMT13" "$GROUP")
qsub -N "${JOB_ID1}"  -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Samtools1-3Bcftools.sh "${arr13[@]}"
qsub -N "${JOB_ID1b}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Samtools1-3Bcftools.sh "${arr14[@]}"
JOBHOLD="${JOBHOLD},${JOB_ID1},${JOB_ID1b}"
done

#2# bgzip/tabix each vcf
JOBHOLD2="NONE"
for GROUP in "${INALL[@]}"; do
JOB_ID2="tb_${GROUP}_${SAMPLE_ID}"
JOB_ID2b="tb_${GROUP}_${SAMPLE_ID2}"
arr2=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "${REF_BUILD}" "$SMT13" "$GROUP")
arr2b=("${SAMPLE_ID2}" "${SAMPLE_PATH}" "$Q" "${REF_BUILD2}" "$SMT13" "$GROUP")
qsub -hold_jid "${JOBHOLD}" -N "${JOB_ID2}"  -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Bgzip_tabix.sh "${arr2[@]}"
qsub -hold_jid "${JOBHOLD}" -N "${JOB_ID2b}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Bgzip_tabix.sh "${arr2b[@]}"
JOBHOLD2="${JOBHOLD2},${JOB_ID2},${JOB_ID2b}"
done

#3# Merge all group vcfs
JOB_ID3="mg_${SAMPLE_ID}"
JOB_ID3b="mg_${SAMPLE_ID2}"
arr3=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "${REF_BUILD}" "$SMT13")
arr3b=("${SAMPLE_ID2}" "${SAMPLE_PATH}" "$Q" "${REF_BUILD2}" "$SMT13")
qsub -hold_jid "${JOBHOLD},${JOBHOLD2}" -N "${JOB_ID3}"  -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Merge_vcfs.sh "${arr3[@]}"
qsub -hold_jid "${JOBHOLD},${JOBHOLD2}" -N "${JOB_ID3b}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Merge_vcfs.sh "${arr3b[@]}"

#4# Combine hg38 and hg38plus vcfs
JOB_ID4="Combine_${SAMPLE_ID}"
INDIR1="${SAMPLE_PATH}/${SAMPLE_ID}"
INDIR2="${SAMPLE_PATH}/${SAMPLE_ID2}"
SAMVCF1="${SAMPLE_ID}_Merge_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}.vcf"
SAMVCF2="${SAMPLE_ID2}_Merge_SourceBio_Q${Q}_Bcftools13_${REF_BUILD2}.vcf"
arr15=("${INDIR1}" "${INDIR2}" "${SAMVCF1}" "${SAMVCF2}" "${SCRIPT_PATH}" "${PRL}" "${SAMPLE_ID}")
qsub -hold_jid "${JOBHOLD},${JOBHOLD2},${JOB_ID2},${JOB_ID2b},${JOB_ID3},${JOB_ID3b}" -N "${JOB_ID4}" -q "$BMQ" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Combine_hg38_andplusVCFs.sh "${arr15[@]}"

#5# Annotate Variant Calls for single (combined-ref multisample) vcf file
JOB_ID5="Annovar_${SAMPLE_ID}"
arr5=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "$ANV" "${REF_BUILD}" "${IntGENES}" "${IHMAF}" "$PRL" "$VTL" "$SMT")
qsub -hold_jid "${JOBHOLD},${JOBHOLD2},${JOB_ID2},${JOB_ID2b},${JOB_ID3},${JOB_ID3b},${JOB_ID4}" -N "${JOB_ID5}" -q "$BMQ" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Annovar.sh "${arr5[@]}"

#6# Filter VCF to produce separate files showing 1.only genotypes and 2.only alt-allele frequencies
JOB_ID6="Filter_${SAMPLE_ID}"
FILE="${SAMPLE_ID}_Merge_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}_combined.${REF_BUILD}_multianno.vcf"
arr6=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "${REF_BUILD}" "$PRL" "${SCRIPT_PATH}" "${FILE}")
qsub -hold_jid "${JOBHOLD},${JOBHOLD2},${JOB_ID2},${JOB_ID2b},${JOB_ID3},${JOB_ID3b},${JOB_ID4},${JOB_ID5}" -N "${JOB_ID6}" -q "$BMQ" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/Get_genos_depths.sh "${arr6[@]}"
