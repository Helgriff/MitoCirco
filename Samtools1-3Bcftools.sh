#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ########################
module load $8
#######################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
Q=$3
MaxD=$4
REF_BUILD=$5
REF_FILE=$6
BAMFILELIST=$7
GROUP=$9

INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
SAMVCF="${INDIR}/${SAMPLE_ID}_${GROUP}_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}.vcf"

##Samtools-Bcftools Variant Calling
#samtools mpileup -v -d $MaxD -L $MaxD -q $Q -Q $Q -m 25 -t DP,AD,ADF,ADR,SP,INFO/AD,INFO/ADF,INFO/ADR -r chrM:0-16570 -f ${REF_FILE} -b ${BAMFILELIST} | bcftools call -v -m -f GQ,GP -O v -o $SAMVCF -
# -I no Indels called/SNPs only bcftools w/o '-v' calls at every position
samtools mpileup -vu -d $MaxD -q $Q -Q $Q -I -t DP,AD,ADF,ADR,SP -r chrM -f ${REF_FILE} -b ${BAMFILELIST} | bcftools call -m -f GQ,GP -O v -o $SAMVCF -
#samtools mpileup -vu -d $MaxD -q $Q -Q $Q -I -t DP,DP4,SP -r chrM:0-16570 -f ${REF_FILE} -b ${BAMFILELIST} | bcftools call -v -m -f GQ,GP -O v -o $SAMVCF -
echo $'\n'"["`date`"]: Variant Calling by Samtools-Bcftools is Complete!!"

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
