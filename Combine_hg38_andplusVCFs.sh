#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ########################
module load $6
#######################################

INDIR1=$1
INDIR2=$2
SAMVCF1=$3
SAMVCF2=$4
SCRIPTPATH=$5
SAMPLEID=$7

##Combine VCFs using perl script
perl "${SCRIPTPATH}/PerlScripts/Format_hg38_hg38plus_vcfs_into_oneFile.pl" ${INDIR1} ${INDIR2} ${SAMVCF1} ${SAMVCF2} ${SAMPLEID}

echo $'\n'"["`date`"]: Combined vcf complete!!"

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
