#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ########################
module load $8 $9 ${10}
#######################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
Q=$3
ANNOVAR_PATH=$4
REF_BUILD=$5
IntGENES=$6
INHOUSE_MAF=$7

INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
SAM13bVCF="${SAMPLE_PATH}/${SAMPLE_ID}_Merge_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}_combined.vcf"
S13bOUT="${SAMPLE_PATH}/${SAMPLE_ID}_Merge_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}_combined"
#SAM13VCF="${INDIR}/${SAMPLE_ID}_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}.vcf"
#S13OUT="${INDIR}/${SAMPLE_ID}_SourceBio_Q${Q}_Bcftools13_${REF_BUILD}"

##Annovar (reduced number of annotations for chrM variants only)
${ANNOVAR_PATH}/table_annovar.pl "${SAM13bVCF}" --outfile "${S13bOUT}" "${ANNOVAR_PATH}/humandb" \
--vcfinput \
--buildver ${REF_BUILD} \
--protocol knownGene,dbnsfp31a_interpro,kaviar_20150923,mitimpact24 \
--operation g,f,f,f \
--nastring . \
--otherinfo

##Annovar
# ${ANNOVAR_PATH}/table_annovar.pl "${SAM13VCF}" --outfile "${S13OUT}" "${ANNOVAR_PATH}/humandb" \
#--vcfinput \
#--buildver ${REF_BUILD} \
#--protocol knownGene,refGene,exac03,esp6500siv2_all,avsnp144,cosmic70,clinvar_20151201,dbnsfp30a,dbnsfp31a_interpro,dbscsnv11,hrcr1,kaviar_20150923,nci60,mitimpact24 \
#--operation g,g,f,f,f,f,f,f,f,f,f,f,f,f \
#--nastring . \
#--otherinfo

SAMPLE_S13bVCF="${S13bOUT}.${REF_BUILD}_multianno.vcf"
#SAMPLE_S13VCF="${S13OUT}.${REF_BUILD}_multianno.vcf"

###VCFtools - Filter Annotated vcf for 'InterestingGenes' only
# vcftools --vcf "${SAMPLE_SVCF}" --bed "${IntGENES}" --recode --recode-INFO-all --out "${SOUT}.${REF_BUILD}_multianno_IntGenes.vcf"

###VCFtools - Add InHouse/Pipeline specific MAFs (currently only hg19 called Inhouse vcfs!!)
#cat "${SAMPLE_SVCF}" | vcf-annotate -a "${INHOUSE_MAF}" -c CHROM,FROM,REF,ALT,-,-,-,INFO/MAF_IH -d key=INFO,ID=MAF_IH,Number=1,Type=Float,Description='InHouse and/or pipeline specific Minor Allele Frequencies' > "${SAMPLE_SVCF}_InHouseMAFs.vcf"

###add other custom filters for strands, depth, rare, exonic, known pathogenic, etc...
##Write to txt/excel file (perl script "VCF_to_Excel.pl")

## Final Cleaning
#rm ${S13OUT}.avinput ${S13OUT}.knownGene* ${S13OUT}.refGene* ${S13OUT}.log ${S13OUT}.${REF_BUILD}_*_filtered ${S13OUT}.${REF_BUILD}_*_dropped
rm ${S13bOUT}.avinput ${S13bOUT}.knownGene* ${S13bOUT}.log ${S13bOUT}.${REF_BUILD}_*_filtered ${S13bOUT}.${REF_BUILD}_*_dropped

echo $'\n'"["`date`"]: Annotation of ${SAMPLE_ID} variants is Complete!!"

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
