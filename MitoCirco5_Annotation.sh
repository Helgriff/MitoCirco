#! /bin/bash
#$ -cwd -V
#$ -j y
#$ -m e

set -e
res1=$(date +%s.%N) # use to calculate whole run time of the job

echo $'\n'"["`date`"]: Job started."

## Add Modules ########################
module load ${11} ${12} ${14}
#######################################

SAMPLE_ID=$1
SAMPLE_PATH=$2
SCRIPT_PATH=$3
REFDIR=$4
REF_FA=$5
TARGETS=$6
Batch_ID=$7
Q=$8
TYPE=$9
ANNOVAR_PATH=${10}
REF_BUILD=${13}
IntGENES=${15}
INHOUSE_MAF=${16}
REF_FILE="${REFDIR}/${REF_FA}"

INDIR="${SAMPLE_PATH}/${SAMPLE_ID}"
SAMTOOLS_BCF_DIR="${INDIR}/Samtools_bcftools"
VCF="${SAMTOOLS_BCF_DIR}/${SAMPLE_ID}_sambcftools_nodups_${REF_BUILD}.vcf"
OUT="${SAMTOOLS_BCF_DIR}/${SAMPLE_ID}_sambcftools_nodups"

##Annovar
${ANNOVAR_PATH}/table_annovar.pl "${VCF}" --outfile "${OUT}" "${ANNOVAR_PATH}/humandb" \
--vcfinput \
--buildver ${REF_BUILD} \
--protocol knownGene,refGene,exac03,esp6500siv2_all,avsnp144,cosmic70,clinvar_20151201,dbnsfp30a,dbnsfp31a_interpro,dbscsnv11,hrcr1,kaviar_20150923,nci60,mitimpact24 \
--operation g,g,f,f,f,f,f,f,f,f,f,f,f,f \
--nastring . \
--otherinfo

##OLDER PROTOCOL ensGene,knownGene,refGene,MT_ensGene,exac03,esp6500siv2_all,cg69,snp138NonFlagged,avsnp142,ljb26_all,cosmic68wgs,clinvar_20150330,gerp++gt2,mitimpact2

SAMPLE_VCF="${OUT}.${REF_BUILD}_multianno.vcf"

###VCFtools - Filter Annotated vcf for 'InterestingGenes' only
vcftools --vcf "${SAMPLE_VCF}" --bed "${IntGENES}" --recode --recode-INFO-all --out "${OUT}.${REF_BUILD}_multianno_IntGenes.vcf"

###VCFtools - Add InHouse/Pipeline specific MAFs
cat "${SAMPLE_VCF}" | vcf-annotate -a "${INHOUSE_MAF}" -c CHROM,FROM,REF,ALT,-,-,-,INFO/MAF_IH -d key=INFO,ID=MAF_IH,Number=1,Type=Float,Description='InHouse and/or pipeline specific Minor Allele Frequencies' > "${SAMPLE_VCF}_InHouseMAFs.vcf"

###add other custom filters for strands, depth, rare, exonic, known pathogenic, etc...
##vcf to plink format
##Write to excel file (custom perl script)

## Final Cleaning
rm ${OUT}.avinput ${OUT}.knownGene* ${OUT}.refGene* ${OUT}.log ${OUT}.${REF_BUILD}_*_filtered ${OUT}.${REF_BUILD}_*_dropped

echo $'\n'"["`date`"]: MitoCirco5_Annotation is Complete!!"

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
