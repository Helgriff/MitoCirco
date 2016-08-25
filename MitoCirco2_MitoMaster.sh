#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -l h_vmem=10G
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job
echo $'\n'"["`date`"]: Job started."

SAMPLE_ID=$1
SAMPLE_PATH=$2
REF_DIR2=$3 #rCRS
REF_FA2=$4  #rCRS.fasta
SCRIPT_PATH=$5
PCNT_HOMO=$6
TYPE=$7
MM_DATA=$8
REF_FILE2="${REF_DIR2}/${REF_FA2}" #rCRS
INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
VARSCAN_OUT_DIR="${INDIR}/varscan2"

perl "${SCRIPT_PATH}/PerlScripts/Haplogrep_inFile.pl" ${VARSCAN_OUT_DIR} ${SAMPLE_ID} ${REF_FILE2} ${PCNT_HOMO} ## Haplogrep and Summary Heteroplasmy Statistics

#Only Query Heteroplasmic Variants through MM api when not present in local data file
MMOut2="${VARSCAN_OUT_DIR}/MitoMasterOut_lessthan_${PCNT_HOMO}pcnt_Heteroplasmic_${SAMPLE_ID}.txt"
perl "${SCRIPT_PATH}/PerlScripts/MitoMaster_api3.pl" ${VARSCAN_OUT_DIR} ${SAMPLE_ID} ${PCNT_HOMO} ${MM_DATA} ## Get MitoMaster heteroplasmic vars input SNV file
perl "${SCRIPT_PATH}/PerlScripts/MitoMaster_api2.pl" ${VARSCAN_OUT_DIR} "MitoMaster_In_${SAMPLE_ID}_Heteroplasmies.txt" "snvlist" > "${MMOut2}" ## Run MitoMaster API on heteroplasmic SNVs

MMOut="${VARSCAN_OUT_DIR}/MitoMasterOut_morethan_${PCNT_HOMO}pcnt_Homoplasmic_${SAMPLE_ID}.txt"
perl "${SCRIPT_PATH}/PerlScripts/MitoMaster_api.pl" ${VARSCAN_OUT_DIR} ${SAMPLE_ID} ${REF_FILE2} ${PCNT_HOMO} ## Get MitoMaster input FA file
perl "${SCRIPT_PATH}/PerlScripts/MitoMaster_api2.pl" ${VARSCAN_OUT_DIR} "${SAMPLE_ID}.fasta" "sequences" > "${MMOut}" ## Run MitoMaster API on fasta sequence

echo $'\n'"["`date`"]: MitoCirco2_MitoMaster is Complete!!"

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
