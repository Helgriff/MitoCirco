#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -l h_vmem=10G
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job
echo $'\n'"["`date`"]: Job started."

BATCH_ID=$1
SAMPLE_PATH=$2
SCRIPT_PATH=$3
Q=$4
PREFIX=$5
PCNT_HOMO=$6
TYPE=$7
LAUNCH_PATH=$8

RESULTS_DIR="${SAMPLE_PATH}/Results_${BATCH_ID}"
CIRCOS_RES_DIR="${SAMPLE_PATH}/Results_${BATCH_ID}/Circos_plots"

echo $'\n'mkdir ${RESULTS_DIR}
if [ ! -d  ${RESULTS_DIR} ]
then
	mkdir ${RESULTS_DIR}
else
	echo "${RESULTS_DIR} exists"  
fi

echo $'\n'mkdir ${CIRCOS_RES_DIR}
if [ ! -d  ${CIRCOS_RES_DIR} ]
then
	mkdir ${CIRCOS_RES_DIR}
else
	echo "${CIRCOS_RES_DIR} exists"  
fi

##Scripts to summarize results into one file and place in Results directory
more ${SAMPLE_PATH}/${PREFIX}*/coverage/Coverage_from_pileup-mean_bases_chrM* > "${SAMPLE_PATH}/Coverage_MeanBases_chrM_${BATCH_ID}.txt2"
more ${SAMPLE_PATH}/${PREFIX}*/coverage/Coverage_from_pileup-mean_bases_chrAll* > "${SAMPLE_PATH}/Coverage_MeanBases_chrAll_${BATCH_ID}.txt2"
more ${SAMPLE_PATH}/${PREFIX}*/coverage/Coverage_perTarget*hg38* > "${SAMPLE_PATH}/Coverage_perTarget_${BATCH_ID}.txt2"
more ${SAMPLE_PATH}/${PREFIX}*/varscan2/Main_Haplogrep_In* > "${SAMPLE_PATH}/Haplogrep_In_${BATCH_ID}.txt2"
more ${SAMPLE_PATH}/${PREFIX}*/varscan2/MitoMasterOut_more* > "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_homoplasmic.txt2"
more ${SAMPLE_PATH}/${PREFIX}*/varscan2/MitoMasterOut_less* > "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_heteroplasmic.txt2"
# more ${SAMPLE_PATH}/${PREFIX}*/varscan2/Heteroplasmy_pcnt_CategoryCounts* > "${SAMPLE_PATH}/Heteroplasmy_Summary_${BATCH_ID}.txt2"

perl -ne 'print $_ if $_ !~/[\:\/][\:C]/' "${SAMPLE_PATH}/Coverage_MeanBases_chrM_${BATCH_ID}.txt2" > "${RESULTS_DIR}/Coverage_MeanBases_chrM_${BATCH_ID}.txt"
perl -ne 'print $_ if $_ !~/[\:\/][\:C]/' "${SAMPLE_PATH}/Coverage_MeanBases_chrAll_${BATCH_ID}.txt2" > "${RESULTS_DIR}/Coverage_MeanBases_chrAll_${BATCH_ID}.txt"
perl -ne 'print $_ if $_ !~/[\:\/][\:C]/' "${SAMPLE_PATH}/Coverage_perTarget_${BATCH_ID}.txt2" > "${RESULTS_DIR}/Coverage_perTarget_${BATCH_ID}.txt"
perl -ne 'print $_ if $_ !~/[\:\/R][\:va][\:an]/' "${SAMPLE_PATH}/Haplogrep_In_${BATCH_ID}.txt2" > "${RESULTS_DIR}/Haplogrep_In_${BATCH_ID}.txt"
perl -ne 'print $_ if $_ !~/[\:\/][\:v]/' "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_homoplasmic.txt2" > "${RESULTS_DIR}/MitoMasterOut_Q${Q}_${BATCH_ID}_homoplasmic.txt"
perl -ne 'print $_ if $_ !~/[\:\/][\:v]/' "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_heteroplasmic.txt2" > "${RESULTS_DIR}/MitoMasterOut_Q${Q}_${BATCH_ID}_heteroplasmic.txt"
# perl -ne 'print $_ if $_ !~/[\:\/][\:v]/' "${SAMPLE_PATH}/Heteroplasmy_Summary_${BATCH_ID}.txt2" > "${RESULTS_DIR}/Heteroplasmy_Summary_${BATCH_ID}.txt"

wc -l ${SAMPLE_PATH}/${PREFIX}*/*hg38nc.reads > "${RESULTS_DIR}/Number_hg38_nuclear_reads_${BATCH_ID}.txt"
wc -l ${SAMPLE_PATH}/${PREFIX}*/*hg38plusnc.reads > "${RESULTS_DIR}/Number_hg38plus_nuclear_reads_${BATCH_ID}.txt"

perl "${SCRIPT_PATH}/PerlScripts/Get_Numts_from_sam_links_Files.pl" ${SAMPLE_PATH} ${PREFIX} ${BATCH_ID}
perl "${SCRIPT_PATH}/PerlScripts/Format_Pileups_into_oneFile_transposed.pl" ${SAMPLE_PATH} ${PREFIX} ${Q} ${PCNT_HOMO} ${BATCH_ID} #Heteroplasmy %vars per base

##Print out file of MitoCirco2_MitoMaster.sh jobs which failed
grep -L 'exit status 0' ${LAUNCH_PATH}/MitoCirco2* > "${RESULTS_DIR}/Non0exit_MitoCirco2.txt"

##Move all circos plots to results directory
mv ${SAMPLE_PATH}/${PREFIX}*/circos/*png "${CIRCOS_RES_DIR}"

##Add in step to automatically run 2x MitoSeek summary results perl scripts
##

##cleaning
rm "${SAMPLE_PATH}/Coverage_MeanBases_chrM_${BATCH_ID}.txt2" "${SAMPLE_PATH}/Coverage_MeanBases_chrAll_${BATCH_ID}.txt2" "${SAMPLE_PATH}/Coverage_perTarget_${BATCH_ID}.txt2"
rm "${SAMPLE_PATH}/Haplogrep_In_${BATCH_ID}.txt2" "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_homoplasmic.txt2" "${SAMPLE_PATH}/MitoMasterOut_Q${Q}_${BATCH_ID}_heteroplasmic.txt2"
# rm "${SAMPLE_PATH}/Heteroplasmy_Summary_${BATCH_ID}.txt2"
rm ${SAMPLE_PATH}/${PREFIX}*/coverage/*pileup

echo $'\n'"["`date`"]: MitoCirco3_Summary is Complete!!"

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
