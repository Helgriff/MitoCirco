#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ########################
module load ${10} ${11}
#######################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
Q=$3
MinD=$4
MaxD=$5
MinVFQ=$6
REF_BUILD=$7
REF_FILE=$8
BAMFILELIST=$9
VSN=${12}

INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
VSNVCF="${INDIR}/${SAMPLE_ID}_SourceBio_Q${Q}_Varscan_${REF_BUILD}.vcf"

##Samtools-VarScan2 Variant Calling
samtools mpileup -d $MaxD -q $Q -Q $Q -f ${REF_FILE} -b ${BAMFILELIST} | java -Xmx4g -jar $VSN mpileup2snp - --min-coverage $MinD --min-reads2 $MinD --min-avg-qual $Q --min-var-freq $MinVFQ --output-vcf > $VSNVCF

echo $'\n'"["`date`"]: Variant Calling by Samtools-Varscan2 is Complete!!"

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
