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
REF_FILE2="${REF_DIR2}/${REF_FA2}" #rCRS
REF_FILE3="${REF_DIR3}/${REF_FA3}" #hg38plus
INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
FASTQC_OUTPUT="${SAMPLE_PATH}/FastQC_dupfree"
COV_DIR="${INDIR}/coverage"
DUP_FREE_BAM_DIR="${INDIR}/dup_free_bam"
VARSCAN_OUT_DIR="${INDIR}/varscan2"
PICARDDIR="$PICARD_PATH"
WRKGDIR="$INDIR/${SAMPLE_ID}_tmp"
JAVA_TMP_DIR="${INDIR}/${SAMPLE_ID}.Java.tmp.dir_tmp"
PICARD_TEMP="$WRKGDIR/Picard_Temp"
PICARD_LOG="$WRKGDIR/${SAMPLE_ID}_picard.log"

## prepare folders
echo $'\n'mkdir $FASTQC_OUTPUT
if [ ! -d $FASTQC_OUTPUT ]
then
	mkdir -p $FASTQC_OUTPUT
else
	echo "$FASTQC_OUTPUT exists"  
fi

echo $'\n'mkdir $JAVA_TMP_DIR
if [ ! -d  $JAVA_TMP_DIR ]
then
	mkdir $JAVA_TMP_DIR
else
	echo "$JAVA_TMP_DIR exists"  
fi

echo $'\n'mkdir $WRKGDIR
if [ ! -d $WRKGDIR ]
then
	mkdir $WRKGDIR
else 
	echo "$WRKGDIR exists"	
fi

echo $'\n'mkdir $COV_DIR
if [ ! -d $COV_DIR ]
then
	mkdir $COV_DIR
else
	echo "$COV_DIR exists"   
fi

echo $'\n'mkdir $DUP_FREE_BAM_DIR
if [ ! -d $DUP_FREE_BAM_DIR ]
then
	mkdir ${DUP_FREE_BAM_DIR}
else
	echo "${DUP_FREE_BAM_DIR} exists"   
fi

echo $'\n'mkdir $VARSCAN_OUT_DIR
if [ ! -d $VARSCAN_OUT_DIR ]
then
	mkdir ${VARSCAN_OUT_DIR}
else
	echo "${VARSCAN_OUT_DIR} exists"   
fi

echo $'\n'"mkdir $PICARD_TEMP"
if [ ! -d $PICARD_TEMP ]
then
	mkdir $PICARD_TEMP
else
	echo "$PICARD_TEMP exists"   
fi

#########################
### Loop through per lane
LANES_STRING=`perl ${SCRIPTS_DIR}/PerlScripts/detectSampleLanes_MC.pl $SAMPLE_PATH $SAMPLE_ID`
LANES=($LANES_STRING)

echo "${LANES[@]} ...are the lanes detected!!"

if [ ${#LANES[@]} -lt 1 ]; then
	exit "Error: No lane info detected, check file name patterns and paths"
fi

BAM_FILE_LIST=""
echo $'\n'"started to loop through lanes ..."
for LANE in "${LANES[@]}"
do
	echo "process lane $LANE for sample ${SAMPLE_ID}"

	## Unzip Fastq files and Remove duplicate reads with FastUniq ###
	READ_FILE1gz=( $INDIR/${SAMPLE_ID}*L00${LANE}${FQS1} )
	READ_FILE2gz=( $INDIR/${SAMPLE_ID}*L00${LANE}${FQS2} )
	READ_FILE1gz=${READ_FILE1gz[0]}
	READ_FILE2gz=${READ_FILE2gz[0]}
	echo $READ_FILE1gz; echo $READ_FILE2gz
	
	READ_FILE1=$INDIR/${SAMPLE_ID}_L00${LANE}_R1_001.fastq
	READ_FILE2=$INDIR/${SAMPLE_ID}_L00${LANE}_R2_001.fastq
	READ_FILE1_nodup="$INDIR/${SAMPLE_ID}_L00${LANE}_R1_001.nodup.fastq"
	READ_FILE2_nodup="$INDIR/${SAMPLE_ID}_L00${LANE}_R2_001.nodup.fastq"
	FASTQ_LIST_FILE="$INDIR/${SAMPLE_ID}_L00${LANE}.temp.qlist"
	
		if [ -f $READ_FILE1 ]
		then
			echo "find file $READ_FILE1"
		else
		if [ -f $READ_FILE1gz ]
		then
			echo "find gzipped fastq file $READ_FILE1gz, unzip now.."
			gunzip -c $READ_FILE1gz > ${READ_FILE1}
		else
			exit "fastq file name error, can not find file $READ_FILE1"
			fi
		fi

		if [ -f $READ_FILE2 ]
			then
			echo "find file $READ_FILE2"
		else     
		if [ -f $READ_FILE2gz ]
		then
			echo "find gzipped fastq file $READ_FILE2gz, unzip now.."
            gunzip -c "$READ_FILE2gz" > "$READ_FILE2"
		else
			exit "fastq file name error, can not find file $READ_FILE2"
            fi
        fi

	if [ ! -f ${READ_FILE1_nodup} ]
	then
	echo -e "$READ_FILE1\n$READ_FILE2" > $FASTQ_LIST_FILE
	echo fastuniq -i "${FASTQ_LIST_FILE}" -t q -o "${READ_FILE1_nodup}" -p "${READ_FILE2_nodup}"
	fastuniq -i "${FASTQ_LIST_FILE}" -t q -o "${READ_FILE1_nodup}" -p "${READ_FILE2_nodup}"
	else
		echo "${READ_FILE1_nodup} exists and fastuniq should already have been completed"   
	fi
	#################### End Fastuniq ############

	################## Fastqc ####################
	FASTQC_OUTFILE="${FASTQC_OUTPUT}/${SAMPLE_ID}_R2_001.nodup_fastqc.zip"
	if [ ! -f $FASTQC_OUTFILE ]
	then
	echo "running fastqc on fastqs"
	fastqc --nogroup --noextract --outdir ${FASTQC_OUTPUT}  -q ${READ_FILE1_nodup}
	fastqc --nogroup --noextract --outdir ${FASTQC_OUTPUT}  -q ${READ_FILE2_nodup}
	echo "done!"
	else
		echo "Fastqc complete"
	fi
	################## End #######################

	################## BWA Alignment ####################
	SAM_FILE1hg38="$WRKGDIR/${SAMPLE_ID}_L00${LANE}_hg38.sam"
	RAW_BAMhg38="$SAM_FILE1hg38.bam"
	READNAMEShg38nc="$INDIR/${SAMPLE_ID}_L00${LANE}_hg38nc.reads"
	SAM_FILE1hg38mt="$WRKGDIR/${SAMPLE_ID}_L00${LANE}_hg38mt.sam"
	DUP_FREE_BAM_FILE_LISThg38="$DUP_FREE_BAM_FILE_LISThg38-I ${RAW_BAMhg38}"
	
	SAM_FILE1hg38plus="$WRKGDIR/${SAMPLE_ID}_L00${LANE}_hg38plus.sam"
	RAW_BAMhg38plus="$SAM_FILE1hg38plus.bam"
	READNAMEShg38plusnc="$INDIR/${SAMPLE_ID}_L00${LANE}_hg38plusnc.reads"
	SAM_FILE1hg38plusmt="$WRKGDIR/${SAMPLE_ID}_L00${LANE}_hg38plusmt.sam"
	DUP_FREE_BAM_FILE_LISThg38plus="$DUP_FREE_BAM_FILE_LISThg38plus-I ${RAW_BAMhg38plus}"

	SAM_FILE1rCRS="$WRKGDIR/${SAMPLE_ID}_L00${LANE}_rCRS.sam"
	RAW_BAMrCRS="$SAM_FILE1rCRS.bam"
	DUP_FREE_BAM_FILE_LISTrCRS="$DUP_FREE_BAM_FILE_LISTrCRS-I ${RAW_BAMrCRS}"
	
	if [ ! -f $SAM_FILE1hg38 ]
	then
	echo $'\n'"["`date`"]: bwa starts to align."
	#dupfree hg38
	echo bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE $READ_FILE1_nodup $READ_FILE2_nodup "> $SAM_FILE1hg38"
	bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE $READ_FILE1_nodup $READ_FILE2_nodup > $SAM_FILE1hg38 # "-M" is for Picard compatibility
	#dupfree rCRS
	echo bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE2 $READ_FILE1_nodup $READ_FILE2_nodup "> $SAM_FILE1rCRS"
	bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE2 $READ_FILE1_nodup $READ_FILE2_nodup > $SAM_FILE1rCRS # "-M" is for Picard compatibility
	#dupfree hg38plus
	echo bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE3 $READ_FILE1_nodup $READ_FILE2_nodup "> $SAM_FILE1hg38plus"
	bwa mem -R "@RG\tID:FlowCell.${SAMPLE_ID}\tSM:${SAMPLE_ID}\tPL:${SEQ_PLATFORM}\tLB:${Library_ID}.${SAMPLE_ID}" -M $REF_FILE3 $READ_FILE1_nodup $READ_FILE2_nodup > $SAM_FILE1hg38plus # "-M" is for Picard compatibility
	rm ${READ_FILE1_nodup}
	rm ${READ_FILE2_nodup}
	
	`perl -lane 'print $F[0] if $F[2] =~/chr[1-9XYU]/' ${SAM_FILE1hg38} > ${READNAMEShg38nc}` #get read IDs of nuclear chrom mapped reads
	`perl -lane 'print $F[0] if $F[2] =~/chr[1-9XYU]/' ${SAM_FILE1hg38plus} > ${READNAMEShg38plusnc}` #get read IDs of nuclear chrom mapped reads
	else
		echo "Found Sam file, BWA alignment complete"
	fi
	################# Picard ############################	
	## Picard_FilterSamReads
	if [ "$TYPE" = "Target" ]
	then
	JM="-Xmx4g"
	elif [ "$TYPE" = "Exome" ]
	then
	JM="-Xmx8g"
	else
	JM="-Xmx12g"
	fi

	if [ ! -f $RAW_BAMhg38 ]
	then
	Picard_FilterSam="java -Djava.io.tmpdir=$JAVA_TMP_DIR $JM -jar ${20}/FilterSamReads.jar FILTER=excludeReadList SORT_ORDER=coordinate"
	echo "$Picard_FilterSam"
	$Picard_FilterSam INPUT=${SAM_FILE1hg38} OUTPUT=${SAM_FILE1hg38mt} READ_LIST_FILE=${READNAMEShg38nc} 
	$Picard_FilterSam INPUT=${SAM_FILE1hg38plus} OUTPUT=${SAM_FILE1hg38plusmt} READ_LIST_FILE=${READNAMEShg38plusnc}

	## Picard_sort, Sam to Bam	
	Picard_sort="java -Djava.io.tmpdir=$JAVA_TMP_DIR $JM -jar ${20}/SortSam.jar VALIDATION_STRINGENCY=LENIENT"
	#dupfree hg38
	echo $'\n'"["`date`"]: PICARD to sort the sam file ${SAM_FILE1hg38}"
	echo "$Picard_sort INPUT=$SAM_FILE1hg38 OUTPUT=$RAW_BAMhg38 SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP"
	$Picard_sort INPUT=$SAM_FILE1hg38 OUTPUT=$RAW_BAMhg38 SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP
	echo $'\n'"samtools index $RAW_BAMhg38"
	samtools index $RAW_BAMhg38
	#dupfree rCRS
	echo $'\n'"["`date`"]: PICARD to sort the sam file ${SAM_FILE1rCRS}"
	echo "$Picard_sort INPUT=$SAM_FILE1rCRS OUTPUT=$RAW_BAMrCRS SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP"
	$Picard_sort INPUT=$SAM_FILE1rCRS OUTPUT=$RAW_BAMrCRS SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP
	echo $'\n'"samtools index $RAW_BAMrCRS"
	samtools index $RAW_BAMrCRS
	#dupfree hg38plus
	echo $'\n'"["`date`"]: PICARD to sort the sam file ${SAM_FILE1hg38plus}"
	echo "$Picard_sort INPUT=$SAM_FILE1hg38plus OUTPUT=$RAW_BAMhg38plus SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP"
	$Picard_sort INPUT=$SAM_FILE1hg38plus OUTPUT=$RAW_BAMhg38plus SORT_ORDER=coordinate TMP_DIR=$PICARD_TEMP
	echo $'\n'"samtools index $RAW_BAMhg38plus"
	samtools index $RAW_BAMhg38plus
	else
		echo "Picard Filter/Sort complete"
	fi

done
echo $'\n'"------------------------------"
echo "all lanes have been processed!"
echo $'\n'"------------------------------"
### End of multi-lane ##

### Merge Multi-lane bams
echo $'\n'"Merge alignment and move files"
DUP_FREE_BAMhg38="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}.bam"
DUP_FREE_BAMhg38_IDX="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}.bam.bai"
DUP_FREE_BAMhg38plus="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}plus.bam"
DUP_FREE_BAMhg38plus_IDX="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_${REF_BUILD}plus.bam.bai"
DUP_FREE_BAMrCRS="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_rRCS.bam"
DUP_FREE_BAMrCRS_IDX="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_nodups_rCRS.bam.bai"
if [ ${#LANES[@]} -eq 1 ]
then
	echo "mv $RAW_BAMhg38 $DUP_FREE_BAMhg38"
	mv $RAW_BAMhg38 $DUP_FREE_BAMhg38
	mv "${RAW_BAMhg38}.bai" "${DUP_FREE_BAMhg38_IDX}"
	echo "mv $RAW_BAMhg38plus $DUP_FREE_BAMhg38plus"
	mv $RAW_BAMhg38plus $DUP_FREE_BAMhg38plus
	mv "${RAW_BAMhg38plus}.bai" "${DUP_FREE_BAMhg38plus_IDX}"
	echo "mv $RAW_BAMrCRS $DUP_FREE_BAMrCRS"
	mv $RAW_BAMrCRS $DUP_FREE_BAMrCRS
	mv "${RAW_BAMrCRS}.bai" "${DUP_FREE_BAMrCRS_IDX}"
else # merge with GATK printReads
	##hg38
	echo $'\n'"java -Xmx8g -Djava.io.tmpdir=${JAVA_TMP_DIR} -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE $DUP_FREE_BAM_FILE_LISThg38 -o $DUP_FREE_BAMhg38"
    java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE $DUP_FREE_BAM_FILE_LISThg38 -o $DUP_FREE_BAMhg38
    echo "samtools index $DUP_FREE_BAMhg38"
    samtools index $DUP_FREE_BAMhg38
	##hg38plus
	echo $'\n'"java -Xmx8g -Djava.io.tmpdir=${JAVA_TMP_DIR} -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE3 $DUP_FREE_BAM_FILE_LISThg38plus -o $DUP_FREE_BAMhg38plus"
    java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE3 $DUP_FREE_BAM_FILE_LISThg38plus -o $DUP_FREE_BAMhg38plus
    echo "samtools index $DUP_FREE_BAMhg38plus"
    samtools index $DUP_FREE_BAMhg38plus
	##rCRS
	echo $'\n'"java -Xmx8g -Djava.io.tmpdir=${JAVA_TMP_DIR} -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE2 $DUP_FREE_BAM_FILE_LISTrCRS -o $DUP_FREE_BAMrCRS"
    java -Djava.io.tmpdir=$JAVA_TMP_DIR -Xmx8g -jar $GATKDIR/GenomeAnalysisTK.jar -T PrintReads -nct 4 -R $REF_FILE2 $DUP_FREE_BAM_FILE_LISTrCRS -o $DUP_FREE_BAMrCRS
    echo "samtools index $DUP_FREE_BAMrCRS"
    samtools index $DUP_FREE_BAMrCRS
fi
###

##Clean temp dirs
echo rm -r $WRKGDIR
rm -r $WRKGDIR
echo rm -r $JAVA_TMP_DIR
rm -r $JAVA_TMP_DIR

##### bam to sam #################### for Circos Links files #####
SAM_FILE1hg38b="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_hg38.sam"
SAM_FILE1rCRSb="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_rCRS.sam"
SAM_FILE1hg38bplus="${DUP_FREE_BAM_DIR}/${SAMPLE_ID}_hg38plus.sam"

samtools view ${DUP_FREE_BAMhg38} >${SAM_FILE1hg38b}
samtools view ${DUP_FREE_BAMrCRS} >${SAM_FILE1rCRSb}
samtools view ${DUP_FREE_BAMhg38plus} >${SAM_FILE1hg38bplus}

##### Coverage and Varscan variant calls#######################################
PILEUP_NODUPS_FILEhg38="$COV_DIR/${SAMPLE_ID}_nodups_${Q}_hg38.pileup"
PILEUP_NODUPS_FILErCRS="$COV_DIR/${SAMPLE_ID}_nodups_${Q}_rCRS.pileup"
PILEUP_NODUPS_FILEhg38plus="$COV_DIR/${SAMPLE_ID}_nodups_${Q}_hg38plus.pileup"
samtools mpileup -d 10000 -q $Q -Q $Q -f $REF_FILE $DUP_FREE_BAMhg38 > $PILEUP_NODUPS_FILEhg38
samtools mpileup -d 10000 -q $Q -Q $Q -f $REF_FILE2 $DUP_FREE_BAMrCRS > $PILEUP_NODUPS_FILErCRS
samtools mpileup -d 10000 -q $Q -Q $Q -f $REF_FILE3 $DUP_FREE_BAMhg38plus > $PILEUP_NODUPS_FILEhg38plus
perl "${SCRIPTS_DIR}/PerlScripts/Coverage_from_pileup_MitoCirco.pl" --inPath1 $COV_DIR --inPath2 $COV_DIR --inFile $PILEUP_NODUPS_FILEhg38 --batchID ${Library_ID} --targets $TARGETS
perl "${SCRIPTS_DIR}/PerlScripts/Coverage_from_pileup_MitoCirco.pl" --inPath1 $COV_DIR --inPath2 $COV_DIR --inFile $PILEUP_NODUPS_FILErCRS --batchID ${Library_ID} --targets $TARGETS

VVCF_FILEhg38="${VARSCAN_OUT_DIR}/${SAMPLE_ID}_varscan_nodups_hg38.vcf"
echo 'Starting Varscan2.3.1'
java -Xmx4g -jar ${21} mpileup2snp $PILEUP_NODUPS_FILEhg38 --min-coverage 1 --min-reads2 1 --min-avg-qual $Q --min-var-freq 0.001 --output-vcf > $VVCF_FILEhg38
echo 'VarScan -vcf output hg38 aligned has finished'

VVCF_FILErCRS="${VARSCAN_OUT_DIR}/${SAMPLE_ID}_varscan_nodups_rCRS.vcf"
echo 'Starting Varscan2.3.1'
java -Xmx4g -jar ${21} mpileup2snp $PILEUP_NODUPS_FILErCRS --min-coverage 1 --min-reads2 1 --min-avg-qual $Q --min-var-freq 0.001 --output-vcf > $VVCF_FILErCRS
echo 'VarScan -vcf output rCRS aligned has finished'

VVCF_FILEhg38plus="${VARSCAN_OUT_DIR}/${SAMPLE_ID}_varscan_nodups_hg38plus.vcf"
echo 'Starting Varscan2.3.1'
java -Xmx4g -jar ${21} mpileup2snp $PILEUP_NODUPS_FILEhg38plus --min-coverage 1 --min-reads2 1 --min-avg-qual $Q --min-var-freq 0.001 --output-vcf > $VVCF_FILEhg38plus
echo 'VarScan -vcf output hg38plus aligned has finished'
########################################################################

## Final Cleaning
echo 'final cleaning'
echo rm $READ_FILE1
rm ${READ_FILE1}
echo rm $READ_FILE2
rm ${READ_FILE2}
rm ${FASTQ_LIST_FILE}

echo $'\n'"["`date`"]: MitoCirco1_AlignVars is Complete!!"

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
