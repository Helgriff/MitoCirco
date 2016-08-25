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

SAMPLE_ID=$1
SAMPLE_PATH=$2
Q=$3
REFBUILD=$4
INTGENES=$5
PATHS=$7
SCRIPTPATH=$8
FILE=$9

##Get depths and genotypes from combined VCF using perl script
perl "${SCRIPTPATH}/MultiSample_vcf_count_variants_perPathGene.pl" ${SAMPLE_PATH} ${FILE} ${SAMPLE_ID} ${Q} ${REFBUILD} ${INTGENES} ${PATHS}

echo $'\n'"["`date`"]: Annotated Genotype only and Alt-allele freq vcfs complete!!"

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
