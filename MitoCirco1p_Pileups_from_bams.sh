#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ############################################
module load ${13} ${14} ${15} ${16} ${17} ${18} ${19}
export _JAVA_OPTIONS="-XX:-UseLargePages "
##########################################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
SAMPLE_PATH2=${26} #bam_plus directory
SCRIPTS_DIR=$3
REF_DIR=$4  #hg38
REF_DIR2=$5 #rCRS
REF_FA=$6   #hg38.fa
REF_FA2=$7  #rCRS.fasta
REF_DIR3=${24} #hg38plus
REF_FA3=${25}  #hg38plus.fa
TARGETS=$8
SEQ_PLATFORM=ILLUMINA # Valid values are: ILLUMINA, SOLID, LS454, HELICOS and PACBIO
Library_ID=$9
Q=${10}
FQS1=${11}
FQS2=${12}
# PCP=${20}
# VSP=${21}
TYPE=${22}
REF_BUILD=${23}
REF_FILE="${REF_DIR}/${REF_FA}"	   #hg38
REF_FILE3="${REF_DIR3}/${REF_FA3}" #hg38plus

##### Coverage #################
DUP_FREE_BAMhg38="${SAMPLE_PATH}/${SAMPLE_ID}/${SAMPLE_ID}_nodups_${REF_BUILD}.bam"
DUP_FREE_BAMhg38plus="${SAMPLE_PATH2}/${SAMPLE_ID}/${SAMPLE_ID}_nodups_${REF_BUILD}plus.bam"
PILEUP_NODUPS_FILEhg38="${SAMPLE_PATH}/${SAMPLE_ID}/${SAMPLE_ID}_nodups_${Q}_hg38.pileup"
PILEUP_NODUPS_FILEhg38plus="${SAMPLE_PATH2}/${SAMPLE_ID}/${SAMPLE_ID}_nodups_${Q}_hg38plus.pileup"
samtools mpileup -d 10000 -q $Q -Q $Q -f $REF_FILE $DUP_FREE_BAMhg38 > $PILEUP_NODUPS_FILEhg38
samtools mpileup -d 10000 -q $Q -Q $Q -f $REF_FILE3 $DUP_FREE_BAMhg38plus > $PILEUP_NODUPS_FILEhg38plus
########################################################################

echo $'\n'"["`date`"]: MitoCirco1p_Pileups_from_bams is Complete!!"

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
