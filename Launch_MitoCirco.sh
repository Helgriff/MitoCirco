#! /bin/bash

## Script to launch MitoCirco Pipeline on Illumina paired-end sequence reads
## Version 0.0.4 - getting closer to handling Genome & Exome Sequences in addition to targeted sequences

## Parameters that need to be adjusted for different batches of samples
Batch_ID="TEST_03Feb16" ## Sequence batch identifier
TYPE="Target" ## options are "Target", "Exome" or "Genome"
Fastqfile_prefix="PREFIX" ##Common prefix at start of all fastq files
SAMPLE_PATH="/users/id/WORKING_DATA" ##directory containing all gzipped fastq files
LAUNCH_PATH="/users/id/WORKING_DATA/jobs" ##dir from where this .exe is being run
SCRIPT_PATH="/users/id/WORKING_DATA/Pipeline_MitoCirco" ##dir containing all MitoCirco scripts
REFDIR="/users/id/WORKING_DATA/hg38" ##directory containing fasta whole genome reference
REFDIR2="${SCRIPT_PATH}/rCRS" ##directory containing fasta mitochondrial DNA reference
REF_FA="hg38.fa" ##whole genome fasta reference file
REF_FA2="rCRS.fasta" ##mitochondrial DNA fasta reference file
REF_BUILD="hg38" ##for annovar databases
MM_DATA="${REFDIR2}/MitoMasterOut_Data.txt" ##Local copy of MitoMaster Data
## (N.B. sequence names should be chrM, chr1-22,X,Y, otherwise perl regular expressions need to be altered)
Q=25 ##Minimum Quality threshold (per base and read)
PCNT_HOMO=90 ## % above which to call a variant homoplasmic (homoplasmic ref threshold is inverse (100-$PCNT_HOMO))
TARGETS="${SCRIPT_PATH}/rCRS/rCRS_genes_genome_plusNuclearChroms.txt" ##Targets for Coverage script - non-overlapping postions!
DBSNPVCF="/users/id/WORKING_DATA/hg38/GATK_bundle/hg38/human_9606_b142_hg38.vcf" ##GATK hg38 dbSNP vcf (hg38 not working due to chr names/order!)
IntGENES="/users/id/WORKING_DATA/Pipeline_MitoCirco/rCRS/hg38_MitochondrialGenes.txt" ##File of candidate disease genes
IHMAF="/users/id/WORKING_DATA/hg38/InHouse_Pipe_Variants_MAFs_96files.txt.gz" ##InHouse MAFs

## Fastq sequence files with suffix *_R1_001.fastq.gz and *_R2_001.fastq.gz expected, if suffix different, alter here and also in 'dir' array pattern match below
FQ_suffix1="_R1_001.fastq.gz"
FQ_suffix2="_R2_001.fastq.gz"

## Options to increase memory for Exome & Genome job submissions
LMEM="h_vmem=10G" ##Exomes ~40G; Genomes ~150G
BMQ="all.q" ##System specific but possible options include "bigmem.q" or "all.q"
THREADS=2 ##Number of threads for BWA-mem alignment
EMAIL="email@uni.ac.uk" ##email for HPC cluster job reports

## Software Modules to be loaded - HPCluster specific
FAU="apps/fastuniq/1.1"
FQC="apps/fastqc/0.11.2"
BWA="apps/bwa/0.7.12"
SMT="apps/samtools/0.1.19"
JAV="apps/java/jre-1.8.0_25"
VS2="apps/VarScan/2.3.7"
PCD="apps/picard/1.130"
GTK="apps/gatk/3.4-protected"
GTQ="apps/gatk-queue/3.3-protected"
PRL="apps/perl/5.18.2"
VTL="apps/vcftools/0.1.12b"
ANV="/users/id/WORKING_DATA/Pipeline_MitoCirco/annovar_jan2016" ##Pathway to Annovar perl scripts
PCP="/opt/software/bsu/bin" ##Pathway to picard jar files
VSP="/opt/software/bsu/bin/VarScan.v2.3.7.jar" ##Pathway to and varscan2 jar file
GKP="/opt/software/bsu/bin/GenomeAnalysisTK-3.4-46.jar" ##Pathway to and GATK jar file
# CIR="apps/circos/0.66/perl-5.16.1" #Local copy of Circos installed and called by 'circos' command


## SUBMIT JOBS ##
#1# INALL is an array of fastq file names that are put into per sample directories
INALL=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
for pattern in "${INALL[@]}"; do
	dir="${pattern%_R*_001.fastq.gz}"		### Alter fastq SUFFIX here!!
	if [ ! -d  ${dir} ]
	then
		mkdir ${dir}
	else
		echo "${dir} already exists"  
	fi	
	mv ${pattern} ${dir}
done
####

#2# Submit MitoCirco via qsub
INALL2=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
JOBHOLD="NU"
JOBHOLD3="NU" #use this to submit MitoMaster jobs serially
for SampleFolder in "${INALL2[@]}"; do
	SAMPLE_ID="${SampleFolder##*/}"
	echo "${SAMPLE_ID}"
	JOB_ID="MitoCirco1_${SAMPLE_ID}"
	JOB_ID1b="MitoCirco1b_${SAMPLE_ID}"
	JOB_ID2="MitoCirco2_${SAMPLE_ID}"
	JOBHOLD="${JOBHOLD},${JOB_ID2}"
	arr=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${REFDIR}" "${REFDIR2}" "${REF_FA}" "${REF_FA2}" "${TARGETS}" "${Batch_ID}" "$Q" "${FQ_suffix1}" "${FQ_suffix2}" "$FAU" "$FQC" "$BWA" "$SMT" "$PCD" "$JAV" "$VS2" "$PCP" "$VSP" "$TYPE" "${REF_BUILD}")
    arr1b=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "$Q" "$TYPE")
	arr2=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${REFDIR2}" "${REF_FA2}" "${SCRIPT_PATH}" "${PCNT_HOMO}" "$TYPE" "${MM_DATA}")
	qsub -N "${JOB_ID}" -pe smp "$THREADS" -l "$LMEM" -q "$BMQ" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco1_AlignVars.sh "${arr[@]}"
	qsub -hold_jid "${JOB_ID}" -N "${JOB_ID1b}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco1b_CircosPlots.sh "${arr1b[@]}"
    qsub -hold_jid "${JOB_ID},${JOBHOLD3}" -N "${JOB_ID2}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco2_MitoMaster.sh "${arr2[@]}"
	JOBHOLD3="${JOBHOLD3},${JOB_ID2}"
done
####

#3# Get Summary Numbers for All samples once all jobs have finished
JOB_ID3="MitoCirco3_Summary"
arr3=("${Batch_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${Q}" "${Fastqfile_prefix}" "${PCNT_HOMO}" "$TYPE" "${LAUNCH_PATH}")
qsub -hold_jid "${JOBHOLD}" -N "${JOB_ID3}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco3_Summary.sh "${arr3[@]}"
####

#4# Additional Variant Calling from files (Samtools, GATK, etc. (GATK does not currently work with hg38 SNP file?!))
INALL2=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
for SampleFolder in "${INALL2[@]}"; do
	SAMPLE_ID="${SampleFolder##*/}"
	JOB_ID4="MitoCirco4_${SAMPLE_ID}"
	arr4=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${REFDIR}" "${REF_FA}" "${TARGETS}" "${Batch_ID}" "$Q" "$SMT" "$PCD" "$JAV" "$GTK" "$GTQ" "$GKP" "$DBSNPVCF" "$TYPE" "${REF_BUILD}")
	qsub -hold_jid "${JOB_ID2}" -N "${JOB_ID4}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco4_MoreVarCalls.sh "${arr4[@]}"
done
####

#5# Annotate Variant Calls (vcf files)
INALL5=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
for SampleFolder in "${INALL5[@]}"; do
        SAMPLE_ID="${SampleFolder##*/}"
        JOB_ID5="MitoCirco5_${SAMPLE_ID}"
        arr5=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${REFDIR}" "${REF_FA}" "${TARGETS}" "${Batch_ID}" "$Q" "$TYPE" "$ANV" "$PRL" "$VTL" "${REF_BUILD}" "$SMT" "${IntGENES}" "${IHMAF}")
        qsub -hold_jid "${JOB_ID4}" -N "${JOB_ID5}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco5_Annotation.sh "${arr5[@]}"
done
####
