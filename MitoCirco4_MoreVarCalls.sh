#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ############################################
module load ${9} ${10} ${11} ${12} ${13}
export _JAVA_OPTIONS="-XX:-UseLargePages "
##########################################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
SCRIPTS_DIR=$3
REF_DIR=$4
REF_FA=$5   #eg. hg38.fa
TARGETS=$6
Library_ID=$7
Q=$8
GKP=${14}
DBSNP_VCF=${15}
TYPE=${16}
REF_BUILD=${17}
REF_FILE="${REF_DIR}/${REF_FA}"
INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
DUP_FREE_BAM_DIR="${INDIR}/dup_free_bam"
SAMTOOLS_BCF_DIR="${INDIR}/Samtools_bcftools"
GATK_DIR="${INDIR}/GATK"
JAVA_TMP_DIR="${INDIR}/${SAMPLE_ID}.Java.tmp.dir"

## prepare folders
echo $'\n'mkdir $SAMTOOLS_BCF_DIR
if [ ! -d $SAMTOOLS_BCF_DIR ]
then
	mkdir $SAMTOOLS_BCF_DIR
else
	echo "$SAMTOOLS_BCF_DIR exists"  
fi

echo $'\n'mkdir $GATK_DIR
if [ ! -d  $GATK_DIR ]
then
	mkdir $GATK_DIR
else
	echo "$GATK_DIR exists"  
fi

if [ ! -d  $JAVA_TMP_DIR ]
then
	mkdir $JAVA_TMP_DIR
else
    echo "$JAVA_TMP_DIR exists"  
fi

## INPUT BAM FILE ##
DUP_FREE_BAMhg38="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}.bam"
####################

## Call variants using samtools-bcftools ##
SVCF_FILEhg38="${SAMTOOLS_BCF_DIR}/${SAMPLE_ID}_sambcftools_nodups_${REF_BUILD}.vcf"
echo 'Starting Samtools/Bcftools variant calling'
samtools mpileup -u -d 10000 -q $Q -Q $Q -f ${REF_FILE} ${DUP_FREE_BAMhg38} | bcftools view -vcg - > ${SVCF_FILEhg38}
echo 'Samtools/Bcftools -vcf output hg38 aligned has finished'
###########################################

## Call variants using GATK ###############
INTERVALS_LANE="$GATK_DIR/${SAMPLE_ID}_nodups.sorted.bam.intervals"
REALIGNED_BAM_LANE="$GATK_DIR/${SAMPLE_ID}_nodups.sorted.realigned.bam"
RECAL_TABLE_GRP_LANE="$GATK_DIR/${SAMPLE_ID}_nodups.sorted.realigned.bam.grp"
COVARIATES="-cov ReadGroupCovariate -cov QualityScoreCovariate -cov ContextCovariate -cov CycleCovariate"
FINAL_BAM="${GATK_DIR}/${SAMPLE_ID}_nodups.realigned.recalibrated.bam"
	echo $'\n'"["`date`"]:GATK: Creating realignment intervals for $RAW_BAM"
	echo java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T RealignerTargetCreator -I $DUP_FREE_BAMhg38 -R $REF_FILE -o $INTERVALS_LANE
	java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T RealignerTargetCreator -I $DUP_FREE_BAMhg38 -R $REF_FILE -o $INTERVALS_LANE
	echo $'\n'"["`date`"]:GATK: Realigning reads..."
	echo java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T IndelRealigner -I $DUP_FREE_BAMhg38 -R $REF_FILE -targetIntervals $INTERVALS_LANE -o $REALIGNED_BAM_LANE
	java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T IndelRealigner -I $DUP_FREE_BAMhg38 -R $REF_FILE -targetIntervals $INTERVALS_LANE -o $REALIGNED_BAM_LANE
	echo rm $INTERVALS_LANE
	rm $INTERVALS_LANE
	echo $'\n'"["`date`"]:GATK: Calculating recalibration tables..."
	echo java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T BaseRecalibrator -I $REALIGNED_BAM_LANE -R $REF_FILE $COVARIATES -knownSites $DBSNP_VCF -o $RECAL_TABLE_GRP_LANE
	java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T BaseRecalibrator -I $REALIGNED_BAM_LANE -R $REF_FILE $COVARIATES -knownSites $DBSNP_VCF -o $RECAL_TABLE_GRP_LANE
	echo $'\n'"["`date`"]:GATK: Creating Recalibrated alignment file..."
	echo java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T PrintReads -R $REF_FILE -I $REALIGNED_BAM_LANE -BQSR $RECAL_TABLE_GRP_LANE -o $FINAL_BAM
	java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -rf BadCigar -T PrintReads -R $REF_FILE -I $REALIGNED_BAM_LANE -BQSR $RECAL_TABLE_GRP_LANE -o $FINAL_BAM
	echo rm $REALIGNED_BAM_LANE
	rm $REALIGNED_BAM_LANE
	echo rm $RECAL_TABLE_GRP_LANE
	rm $RECAL_TABLE_GRP_LANE
	echo $'\n'"["`date`"]:GATK: Realign & Recalibrate Done..."
	samtools index $FINAL_BAM
echo "produce GVCF!"
OUTPUT_GVCF="${GATK_DIR}/${SAMPLE_ID}_nodups.realigned.recalibrated.g.vcf"
java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GKP -T HaplotypeCaller -R $REF_FILE \
-I $FINAL_BAM \
-o $OUTPUT_GVCF \
-ERC GVCF --variant_index_type LINEAR --variant_index_parameter 128000
##########################################

## Final Cleaning
echo 'final cleaning'
rm -r $JAVA_TMP_DIR

echo $'\n'"["`date`"]: MitoCirco4_MoreVarCalls is Complete!!"

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
