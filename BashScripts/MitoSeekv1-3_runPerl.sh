#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job
echo $'\n'"["`date`"]: Job started."

## Add Modules ####
#module load $6 
## Don't load this perl version (5.18.2) use older version 5.10.1 that was used to build the local perl5 libs required by mitoSeek!!
###################

SAMPLE_ID=$1
SAMPLE_PATH=$2
Q=$3
TYPE=$4
REF_BUILD=$5
MITOSEEK_PATH=$7
LAUNCH_PATH=$8
BASELINEHP=$9
#MITOSEEK_SCRIPT="${MITOSEEK_PATH}/mitoSeek.pl"
MITOSEEK_SCRIPT="${MITOSEEK_PATH}/mitoSeek_HG_Feb2016.pl"
INDIR="${SAMPLE_PATH}/${SAMPLE_ID}" ##MitoSeek perl script automatically outputs to in bam dir. No option to select separate outpur location w/o altering source perl script!!
DUP_FREE_BAM_DIR="${INDIR}/dup_free_bam"
BAM_FILE="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}.bam"
BAM_FILEplus="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}plus.bam"
SAMTOOLS="${MITOSEEK_PATH}/Resources/samtools/samtools"
INREF="rCRS"
OUTREF="rCRS"
ON="off"
#ON="on"

MSK_DIR="${INDIR}/mitoseek"
echo $'\n'mkdir $MSK_DIR
if [ ! -d $MSK_DIR ]
then
	mkdir $MSK_DIR
else
	echo "$MSK_DIR exists"   
fi

## Create a composite bam file from hg38 and hg38plus rCRS references
SAM_FILEplus="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}plus.sam"
SAM_FILEshift="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}shift.sam"
BAM_FILEshift="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}shift.bam"
BAM_FILEshiftsort="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}shift_sorted"

## Run MitoSeek on per sample BAM file
perl ${MITOSEEK_SCRIPT} -i "${BAM_FILE}" -bl ${BASELINEHP} -t 1 -d 50 -hp 1 -mmq ${Q} -mbq ${Q} -sb 0 -r ${INREF} -R ${OUTREF} -cn ${ON} -str 2 -strf 500 -noQC -samtools ${SAMTOOLS}
## Can't use default -sb 10 (strand bias remove top 10%) with targeted sequence because positions of primers can cause reads to be only present on one strand and therefore create artificial strand bias!!

# ${SAMTOOLS} view -h "${BAM_FILEplus}" > "${SAM_FILEplus}"
# perl -lane 'if($_=~/^\@/){print "$_";}elsif($_!~/^\@/){my $p=$F[3]+8260;my $p2=$F[7]+8260;if($p>16569){$p=$F[3]-8309;}if($p2>16569){$p2=$F[7]-8309;} print"$F[0]\t$F[1]\t$F[2]\t$p\t$F[4]\t$F[5]\t$F[6]\t$p2\t$F[8]\t$F[9]\t$F[10]\t$F[11]\t$F[12]\t$F[13]";}' "${SAM_FILEplus}" >"${SAM_FILEshift}"
# ${SAMTOOLS} view -hbS "${SAM_FILEshift}" > "${BAM_FILEshift}"
# ${SAMTOOLS} sort "${BAM_FILEshift}" "${BAM_FILEshiftsort}"
# ${SAMTOOLS} view -b "${BAM_FILEshiftsort}.bam" > "${BAM_FILEshift}"
# perl ${MITOSEEK_SCRIPT} -i "${BAM_FILEshift}" -t 1 -d 50 -ch -hp 1 -mmq ${Q} -mbq ${Q} -sb 0 -r ${INREF} -R ${OUTREF} -cn ${ON} -str 2 -strf 500 -noQC -samtools ${SAMTOOLS}

## Remove older results directories if they exist
MSK_RES_DIR="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}"
MSK_RESshift_DIR="${MSK_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}shift"
if [ -d $MSK_RES_DIR ]
then
	rm -r $MSK_RES_DIR
fi
if [ -d $MSK_RESshift_DIR ]
then
	rm -r $MSK_RESshift_DIR
fi

## Move MitoSeek results to Sample Results directory
mv "${LAUNCH_PATH}/${SAMPLE_ID}_nodups_${REF_BUILD}" "$MSK_DIR/"
# mv "${LAUNCH_PATH}/${SAMPLE_ID}_nodups_${REF_BUILD}shift" "$MSK_DIR/"
mv "$MSK_DIR/${SAMPLE_ID}_nodups_${REF_BUILD}/mito1_heteroplasmy.txt" "$MSK_DIR/${SAMPLE_ID}_nodups_${REF_BUILD}_mitoSK_heteroplasmy.txt"
# mv "$MSK_DIR/${SAMPLE_ID}_nodups_${REF_BUILD}shift/mito1_heteroplasmy.txt" "$MSK_DIR/${SAMPLE_ID}_nodups_${REF_BUILD}plus_mitoSK_heteroplasmy.txt"

##cleaning
# rm "${SAM_FILEplus}" "${SAM_FILEshift}" "${BAM_FILEshiftsort}.bam"

echo $'\n'"["`date`"]: MitoSeekv1-3 is Complete!!"

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
