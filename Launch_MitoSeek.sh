#! /bin/bash

#***************************************************************************************************************************##
## Script to launch MitoSeek							
#***************************************************************************************************************************##

#***************************************************************************************************************************##
## Parameters that need to be adjusted for different batches of samples														
Batch_ID="MS_25Feb16"															   ## Sequence batch identifier
TYPE="Target"																   ## options are "Target", "Exome" or "Genome"
Fastqfile_prefix="WTCCC"														##Common prefix at start of all fastq files
SAMPLE_PATH="/home/WTCCC"	  #directory containing all gzipped fastq files
LAUNCH_PATH="/home/WTCCC/jobs"  #dir from where this .exe is being run
SCRIPT_PATH="/home/Scripts"	#directory containing all MitoCirco scripts
REFDIR="/home/hg38"										 #directory containing fasta whole genome reference
REFDIR2="${SCRIPT_PATH}/rCRS"					 					#directory containing fasta mitochondrial DNA reference
REFDIR3="/home/hg38_rCRS8330"		    		 #directory containing fasta whole genome reference with shifted mtDNA
REF_FA="hg38.fa"											 							 #whole genome fasta reference file
REF_FA2="rCRS.fasta"																#mitochondrial DNA fasta reference file
REF_FA3="hg38_rCRS8330.fa"							#whole genome fasta reference file with mtDNA shifted by 8330 positions
MM_DATA="${REFDIR2}/MitoMasterOut_Data.txt"
BASELINEHP="Heteroplasmy_Baseline_Rate_using_BaselineScript_output_wgtuciE1.txt" #Tab delimited txt file of baseline heteroplasmy values from "Get_Heteroplasmy_Baseline_Values_from_MitoSeekFiles.pl"
## (N.B. sequence names should be chrM, chr1-22,X,Y, otherwise perl regular expressions need to be altered)
Q=25																		 #Minimum Quality threshold (per base and read)
PCNT_HOMO=90  		  # % above which to call a variant homoplasmic (homoplasmic ref threshold is inverse (100-$PCNT_HOMO))
TARGETS="${SCRIPT_PATH}/rCRS/rCRS_genes_genome_plusNuclearChroms.txt" ## Targets for Coverage script - non-overlapping postions!
DBSNPVCF="/home/hg38/GATK_bundle/hg38/human_9606_b142_hg38.vcf"	  #GATK hg38 dbSNP vcf (hg38 doesn't work!)
REF_BUILD="hg38"                                                                               #Ref build for annovar databases ##
IntGENES="/home/rCRS/hg38_MitochondrialGenes.txt"                  #File of candidate disease genes ##
IHMAF="/home/InHouse_FastuniqBWAFreebayesPipe_Variants_MAFs_96files.txt.gz" #InHouse MAFs ##
##																														
## Fastq sequence files with suffix *_R1_001.fastq.gz and *_R2_001.fastq.gz expected, if suffix different, alter here and
## also in 'dir' array pattern match below																				
FQ_suffix1="_R1_001.fastq.gz"																							
FQ_suffix2="_R2_001.fastq.gz"																							
##																														
## Options to increase memory for Exome & Genome job submissions														
LMEM="h_vmem=1G" 																										
BMQ="all.q,bigmem.q"  ##System specific but possible options incluse "bigmem.q" or "all.q"
THREADS=2
EMAIL="email@base.com"
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
PCP="/opt/software/bsu/bin" 								#Pathway to picard jar files
VSP="/opt/software/bsu/bin/VarScan.v2.3.7.jar"				#Pathway to and varscan2 jar file
GKP="/opt/software/bsu/bin/GenomeAnalysisTK-3.4-46.jar"		#Pathway to and GATK jar file
PRL="apps/perl/5.18.2"
VTL="apps/vcftools/0.1.12b"
ANV="/home/annovar_jan2016"   #Pathway to Annovar perl scripts
MSK="/home/MitoSeek-1.3"   #pathway to mitoSeek.pl script
#***************************************************************************************************************************##

#6# MitoSeek v1.3
JOB_ID="NA"
INALL6=( "${SAMPLE_PATH}/${Fastqfile_prefix}"* )
for SampleFolder in "${INALL6[@]}"; do
        SAMPLE_ID="${SampleFolder##*/}"
        JOB_ID6="MitoSeek_${SAMPLE_ID}"
        arr6=("${SAMPLE_ID}" "${SAMPLE_PATH}" "$Q" "$TYPE" "${REF_BUILD}" "$PRL" "$MSK" "${LAUNCH_PATH}" "${BASELINEHP}")
        qsub -hold_jid "${JOB_ID}" -q "$BMQ" -N "${JOB_ID6}" -l "h_vmem=1G" -M "$EMAIL" ${SCRIPT_PATH}/BashScripts/MitoSeekv1-3_runPerl.sh "${arr6[@]}"
done
####
