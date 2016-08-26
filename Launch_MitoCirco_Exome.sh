#! /bin/bash

#***************************************************************************************************************************##
## Script to launch MitoCirco Pipeline on Illumina paired-end sequence reads												##
## Version 0.0.6 - Messy but functional analysis of Exome sequences															##
#***************************************************************************************************************************##

#***************************************************************************************************************************##
## Parameters that need to be adjusted for different batches of samples														
Batch_ID="Test_26Aug16"															   ## Sequence batch identifier
TYPE="Exome"																   ## options are "Target", "Exome" or "Genome"
ORGANISM="Human"															## options are "Human" or "Mouse"
Fastqfile_prefix="PFC"														##Common prefix at start of all fastq files
SAMPLE_PATH="/home/nhrg/WORKING_DATA/Pipeline_MitoCirco/Test_Data/Exome"	  #directory containing all gzipped fastq files
LAUNCH_PATH="/home/nhrg/WORKING_DATA/Pipeline_MitoCirco/Test_Data/Exome/jobs"  #dir from where this .exe is being run
SCRIPT_PATH="/home/nhrg/WORKING_DATA/Pipeline_MitoCirco"	#directory containing all MitoCirco scripts
REFDIR="/home/nhrg/WORKING_DATA/hg38"										 #directory containing fasta whole genome reference
REFDIR2="${SCRIPT_PATH}/rCRS"					 					#directory containing fasta mitochondrial DNA reference
REFDIR3="/home/nhrg/WORKING_DATA/hg38_rCRS8330"		    		 #directory containing fasta whole genome reference with shifted mtDNA
REF_FA="hg38.fa"											 							 #whole genome fasta reference file
REF_FA2="rCRS.fasta"																#mitochondrial DNA fasta reference file
REF_FA3="hg38_rCRS8330.fa"							#whole genome fasta reference file with mtDNA shifted by 8330 positions
MM_DATA="${REFDIR2}/MitoMasterOut_Data.txt"
BASELINEHP="Heteroplasmy_Baseline_Rate_using_BaselineScript_output_wgtuciT-2.txt" #Tab delimited txt file of baseline heteroplasmy values from "Get_Heteroplasmy_Baseline_Values_from_MitoSeekFiles.pl"
## (N.B. sequence names should be chrM, chr1-22,X,Y, otherwise perl regular expressions need to be altered)
Q=25																		 #Minimum Quality threshold (per base and read)
PCNT_HOMO=90  		  # % above which to call a variant homoplasmic (homoplasmic ref threshold is inverse (100-$PCNT_HOMO))
TARGETS="${SCRIPT_PATH}/rCRS/rCRS_genes_genome_plusNuclearChroms.txt" ## Targets for Coverage script - non-overlapping postions!
DBSNPVCF="/home/nhrg/WORKING_DATA/hg38/GATK_bundle/hg38/human_9606_b142_hg38.vcf"	  #GATK hg38 dbSNP vcf (hg38 doesn't work!)
REF_BUILD="hg38"                                                                               #Ref build for annovar databases ##
IntGENES="/home/nhrg/WORKING_DATA/Pipeline_MitoCirco/rCRS/hg38_MitochondrialGenes.txt"                  #File of candidate disease genes ##
IHMAF="/home/nhrg/WORKING_DATA/hg38/InHouse_FastuniqBWAFreebayesPipe_Variants_MAFs_96files.txt.gz" #InHouse MAFs ##
##																														
## Fastq sequence files with suffix *_R1_001.fastq.gz and *_R2_001.fastq.gz expected, if suffix different, alter here and
## also in 'dir' array pattern match below																				
FQ_suffix1="_R1_001.fastq.gz"																							
FQ_suffix2="_R2_001.fastq.gz"																							
##																														
## Options to increase memory for Exome & Genome job submissions														
LMEM="h_vmem=10G" 																										
BMQ="all.q,bigmem.q"  ##System specific but possible options incluse "bigmem.q" or "all.q"
THREADS=2
EMAIL="helen.griffin@ncl.ac.uk"
## Software Modules to be loaded - HPCluster specific															
FAU="apps/fastuniq/1.1"																						
FQC="apps/fastqc/0.11.2"																					
BWA="apps/bwa/0.7.12"																						
SMT="apps/samtools/0.1.19"																					
JAV="apps/java/jre-1.8.0_25"																				
VS2="apps/VarScan/2.3.7"																					
# CIR="apps/circos/0.66/perl-5.16.1" #Local copy of Circos installed and called by 'circos' command
PCD="apps/picard/1.130"																						
GTK="apps/gatk/3.4-protected"																				
GTQ="apps/gatk-queue/3.3-protected"																			
PCP="/opt/software/bsu/bin" 								#Pathway to picard jar files
VSP="/opt/software/bsu/bin/VarScan.v2.3.7.jar"				#Pathway to and varscan2 jar file
GKP="/opt/software/bsu/bin/GenomeAnalysisTK-3.4-46.jar"		#Pathway to and GATK jar file
PRL="apps/perl/5.18.2"
VTL="apps/vcftools/0.1.12b"
ANV="/home/nhrg/WORKING_DATA/Pipeline_MitoCirco/annovar_jan2016"   #Pathway to Annovar perl scripts
MSK="/home/nhrg/MitoSeek-1.3"										#pathway to mitoSeek.pl script
#***************************************************************************************************************************##

#1# It is assumed that fastq files are contained within per sample directories named with the same "${Fastqfile_prefix}" 

#2# Submit MitoCirco via qsub ## (If paired fastq sequence files are already in per sample directories of the fastq file name prefix, comment out stage1 and start from this stage(2))
INALL2=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
JOBHOLD="NU"
JOBHOLD3="NU" #use this to submit MitoMaster jobs serially
for SampleFolder in "${INALL2[@]}"; do
	SAMPLE_ID="${SampleFolder##*/}"
	echo "${SAMPLE_ID}"
	JOB_ID="MitoCirco1_${SAMPLE_ID}"
	JOB_ID1b="MitoCirco1b_${SAMPLE_ID}"
	JOB_ID2="MitoCirco2_${SAMPLE_ID}"
	JOB_ID6="MitoSeek_${SAMPLE_ID}"
	JOBHOLD="${JOBHOLD},${JOB_ID2},${JOB_ID1b}"
	arr=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${REFDIR}" "${REFDIR2}" "${REF_FA}" "${REF_FA2}" "${TARGETS}" "${Batch_ID}" "$Q" "${FQ_suffix1}" "${FQ_suffix2}" "$FAU" "$FQC" "$BWA" "$SMT" "$PCD" "$JAV" "$VS2" "$PCP" "$VSP" "$TYPE" "${REF_BUILD}" "${REFDIR3}" "${REF_FA3}")
    arr1b=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "$Q" "$TYPE" "$SMT")
	arr2=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${REFDIR2}" "${REF_FA2}" "${SCRIPT_PATH}" "${PCNT_HOMO}" "$TYPE" "${MM_DATA}")
	arr6=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "$TYPE" "${REF_BUILD}" "$PRL" "$MSK" "${LAUNCH_PATH}" "${BASELINEHP}")
	qsub -N "${JOB_ID}" -pe smp "$THREADS" -l "$LMEM" -q "$BMQ" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco1_AlignVars_Exome.sh "${arr[@]}"
	qsub -hold_jid "${JOB_ID}" -N "${JOB_ID6}" -q "$BMQ" -l "h_vmem=1G" -M "$EMAIL" ${SCRIPT_PATH}/MitoSeekv1-3_runPerl.sh "${arr6[@]}"
	qsub -hold_jid "${JOB_ID6}" -N "${JOB_ID1b}" -l "$LMEM" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco1b_CircosPlots.sh "${arr1b[@]}"
    qsub -hold_jid "${JOB_ID},${JOBHOLD3}" -N "${JOB_ID2}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco2_MitoMaster.sh "${arr2[@]}"
	JOBHOLD3="${JOBHOLD3},${JOB_ID2}"
done
####

#3# Get Summary Numbers for All samples once all jobs have finished
JOB_ID3="MitoCirco3_Summary"
arr3=("${Batch_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${Q}" "${Fastqfile_prefix}" "${PCNT_HOMO}" "$TYPE" "${LAUNCH_PATH}")
qsub -hold_jid "${JOBHOLD}" -N "${JOB_ID3}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco3_Summary.sh "${arr3[@]}"
####

#4# Additional Variant Calling from files (Samtools, GATK, etc..... (GATK does not currently work with hg38 SNP file?!))
INALL2=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
for SampleFolder in "${INALL2[@]}"; do
	SAMPLE_ID="${SampleFolder##*/}"
	JOB_ID4="MitoCirco4_${SAMPLE_ID}"
	arr4=("${SAMPLE_ID}" "${SAMPLE_PATH}" "${SCRIPT_PATH}" "${REFDIR}" "${REF_FA}" "${TARGETS}" "${Batch_ID}" "$Q" "$SMT" "$PCD" "$JAV" "$GTK" "$GTQ" "$GKP" "$DBSNPVCF" "$TYPE" "${REF_BUILD}")
	qsub -hold_jid "${JOB_ID3}" -N "${JOB_ID4}" -M "$EMAIL" ${SCRIPT_PATH}/MitoCirco4_MoreVarCalls.sh "${arr4[@]}"
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
