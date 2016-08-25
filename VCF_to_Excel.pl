#!/usr/bin/perl

#Script to convert vcf file to tab delim text file that can be input to excel

#my $path1="/users/nhrg/lustre/AnalysisScripts/WTCCC10K/Pipeline_MitoCirco/Test_Data"; ##path to directory containing vcf file
my $path1="/users/nhrg/lustre/Boglarka_HMN/c9orf65_PFC0220";
#my $VCF_prefix="Haplogroup";
my $VCF_prefix="PFC_0220_LC";
my $VCF_suffix="_Freebayes.vcf_chr12_c9orf65.txt.hg19_multianno.vcf_MAFN281.vcf";
#my $VCF_suffix="_SourceBio_Q25_Varscan_hg38.hg38_multianno.vcf";

#($path1, $VCF_prefix, $VCF_suffix)=@ARGV;

#define variables
my $vcf_file=$path1."/".$VCF_prefix.$VCF_suffix;
my $txt_file=$vcf_file."txt";
my %info;

#Read each VCF file line into %info and print to txt files
open(OUT, ">$txt_file") || die "Cannot open file \"$txt_file\" to write to!\n";
open INPUT2, $vcf_file or die "Cannot open $vcf_file\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#\#/){next loop2;}
		my @lsplit=split(/\t/,$Line);
		
		#extract header line info
		if($Line=~/\#CHROM/){
			#SAMBCF ##CHROM	POS	ID	REF	ALT	QUAL	FILTER	(INFO1)	FORMAT	NDCN_1175_AGGTAAGA_L005	NDCN_2453_TCTAGCGT_L006	WTCCC125661_AGTAGATC_L003	WTCCC125662_AGACTATA_L003	WTCCC126287_TCACAGCA_L003	WTCCC126463_CACGAGAT_L003
			#SAMVARSCAN2 ##CHROM	POS	ID	REF	ALT	QUAL	FILTER	(INFO2)	FORMAT	Sample1	Sample2	Sample3	Sample4	Sample5	Sample6
			for(my $c=0;$c<7;$c++){print OUT "$lsplit[$c]\t";}
			my @headA=("TS","TG","HmR","Ht","HmV","MAF","ADP","WT","HET","HOM","NC","DP","VDB","RPB","AF1","AC1","DP4","MQ","FQ","PV4",
			"FuncENSGene","GeneENSGene","GeneDetailENSGene","ExonicFuncENSGene","AAChangeENSGene",
			"FuncknownGene","GeneknownGene","GeneDetailknownGene","ExonicFuncknownGene","AAChangeknownGene",
			"MAF281_inHouse_FreeBayes","ExAC_ALL","esp6500siv2all","cg69","avsnp144","avsnp142","cosmic70","clinvar20151201","SIFT_pred","Polyphen2_HDIV_pred",
			"Polyphen2_HVAR_pred","LRT_pred","MutationTaster_pred","MutationAssessor_pred","FATHMM_pred","PROVEAN_pred","VEST3_score","CADD_raw","CADD_phred",
			"DANN_score","fathmm-MKL_coding_pred","MetaSVM_pred","MetaLR_pred","integrated_fitCons_score","integrated_confidence_value","GERP++_RS",
			"phyloP20way_mammalian","phastCons20way_mammalian","SiPhy_29way_logOdds","Interpro_domain","dbscSNV_ADA_SCORE","dbscSNV_RF_SCORE","HRC_AF",
			"HRC_non1000G_AF","Kaviar_AF","nci60","MitImpact_id","Gene_symbol","OXPHOS_complex","Ensembl_gene_id","Ensembl_protein_id","Ensembl_transcript_id",
			"Uniprot_name","Uniprot_id","Ncbi_gene_id","Ncbi_protein_id","Gene_position","AA_position","AA_ref","AA_alt","Codon_substitution","PhyloP_100V",
			"PhastCons_100V","SiteVar","PolyPhen2","SIFT","FatHmm_pred","FatHmmW","PROVEAN","MutationAssessor","EFIN_SP","EFIN_HD","CADD_phred","CADD",
			"VEST_pvalue","VEST_FDR","PANTHER","PhD-SNP","SNAP","Meta-SNP","Meta-SNP_RI","CAROL","Condel","COVEC_WMV","PolyPhen2_transf","SIFT_transf",
			"MutationAssessor_transf","CHASM_pvalue","CHASM_FDR","MISTIC_coevo_sites","MISTIC_mean_MI_score","Variant_status","Associated_disease",
			"Variant_class","APOGEE_probN","APOGEE_probP","APOGEE");
			for(my $c1=0;$c1<scalar(@headA);$c1++){print OUT "$headA[$c1]\t";}
			for(my $c2=8;$c2<scalar(@lsplit);$c2++){print OUT "$lsplit[$c2]\t";}#genotype only header
			for(my $c2=8;$c2<scalar(@lsplit);$c2++){print OUT "$lsplit[$c2]\t";}#full geno + info header
			print OUT "END\n";
			next loop2;
			}#end header line
		
#Initialise %info keys
$info{'TS'}=".";
$info{'TG'}=".";
$info{'HmR'}=".";
$info{'Ht'}=".";
$info{'HmV'}=".";
$info{'MAF'}=".";
$info{'ADP'}=".";
$info{'WT'}=".";
$info{'HET'}=".";
$info{'HOM'}=".";
$info{'NC'}=".";
$info{'DP'}=".";
$info{'VDB'}=".";
$info{'RPB'}=".";
$info{'AF1'}=".";
$info{'AC1'}=".";
$info{'DP4'}=".";
$info{'MQ'}=".";
$info{'FQ'}=".";
$info{'PV4'}=".";
$info{'FuncENSGene'}=".";
$info{'GeneENSGene'}=".";
$info{'GeneDetailENSGene'}=".";
$info{'ExonicFuncENSGene'}=".";
$info{'AAChangeENSGene'}=".";
$info{'FuncknownGene'}=".";
$info{'GeneknownGene'}=".";
$info{'GeneDetailknownGene'}=".";
$info{'ExonicFuncknownGene'}=".";
$info{'AAChangeknownGene'}=".";
$info{'MAF281'}=".";
$info{'ExAC_ALL'}=".";
$info{'esp6500siv2all'}=".";
$info{'avsnp144'}=".";
$info{'avsnp142'}=".";
$info{'cg69'}=".";
$info{'cosmic70'}=".";
$info{'clinvar20151201'}=".";
$info{'SIFT_pred'}=".";
$info{'Polyphen2_HDIV_pred'}=".";
$info{'Polyphen2_HVAR_pred'}=".";
$info{'LRT_pred'}=".";
$info{'MutationTaster_pred'}=".";
$info{'MutationAssessor_pred'}=".";
$info{'FATHMM_pred'}=".";
$info{'PROVEAN_pred'}=".";
$info{'VEST3_score'}=".";
$info{'CADD_raw'}=".";
$info{'CADD_phred'}=".";
$info{'DANN_score'}=".";
$info{'fathmm-MKL_coding_pred'}=".";
$info{'MetaSVM_pred'}=".";
$info{'MetaLR_pred'}=".";
$info{'integrated_fitCons_score'}=".";
$info{'integrated_confidence_value'}=".";
$info{'GERP++_RS'}=".";
$info{'phyloP20way_mammalian'}=".";
$info{'phastCons20way_mammalian'}=".";
$info{'SiPhy_29way_logOdds'}=".";
$info{'Interpro_domain'}=".";
$info{'dbscSNV_ADA_SCORE'}=".";
$info{'dbscSNV_RF_SCORE'}=".";
$info{'HRC_AF'}=".";
$info{'HRC_non1000G_AF'}=".";
$info{'Kaviar_AF'}=".";
$info{'nci60'}=".";
$info{'MitImpact_id'}=".";
$info{'Gene_symbol'}=".";
$info{'OXPHOS_complex'}=".";
$info{'Ensembl_gene_id'}=".";
$info{'Ensembl_protein_id'}=".";
$info{'Ensembl_transcript_id'}=".";
$info{'Uniprot_name'}=".";
$info{'Uniprot_id'}=".";
$info{'Ncbi_gene_id'}=".";
$info{'Ncbi_protein_id'}=".";
$info{'Gene_position'}=".";
$info{'AA_position'}=".";
$info{'AA_ref'}=".";
$info{'AA_alt'}=".";
$info{'Codon_substitution'}=".";
$info{'PhyloP_100V'}=".";
$info{'PhastCons_100V'}=".";
$info{'SiteVar'}=".";
$info{'PolyPhen2'}=".";
$info{'SIFT'}=".";
$info{'FatHmm_pred'}=".";
$info{'FatHmmW'}=".";
$info{'PROVEAN'}=".";
$info{'MutationAssessor'}=".";
$info{'EFIN_SP'}=".";
$info{'EFIN_HD'}=".";
$info{'CADD_phred'}=".";
$info{'CADD'}=".";
$info{'VEST_pvalue'}=".";
$info{'VEST_FDR'}=".";
$info{'PANTHER'}=".";
$info{'PhD-SNP'}=".";
$info{'SNAP'}=".";
$info{'Meta-SNP'}=".";
$info{'Meta-SNP_RI'}=".";
$info{'CAROL'}=".";
$info{'Condel'}=".";
$info{'COVEC_WMV'}=".";
$info{'PolyPhen2_transf'}=".";
$info{'SIFT_transf'}=".";
$info{'MutationAssessor_transf'}=".";
$info{'CHASM_pvalue'}=".";
$info{'CHASM_FDR'}=".";
$info{'MISTIC_coevo_sites'}=".";
$info{'MISTIC_mean_MI_score'}=".";
$info{'Variant_status'}=".";
$info{'Associated_disease'}=".";
$info{'Variant_class'}=".";
$info{'APOGEE_probN'}=".";
$info{'APOGEE_probP'}=".";
$info{'APOGEE'}=".";

		#extract annotation information
		if($Line=~/TS\=(\S+?)\;/){$info{'TS'}=$1;}
		if($Line=~/TG\=(\S+?)\;/){$info{'TG'}=$1;}
		if($Line=~/HmR\=(\S+?)\;/){$info{'HmR'}=$1;}
		if($Line=~/Ht\=(\S+?)\;/){$info{'Ht'}=$1;}
		if($Line=~/HmV\=(\S+?)\;/){$info{'HmV'}=$1;}
		if($Line=~/MAF\=(\S+?)\;/){$info{'MAF'}=$1;}
		if($Line=~/ADP\=(\S+?)\;/){$info{'ADP'}=$1;}
		if($Line=~/WT\=(\S+?)\;/){$info{'WT'}=$1;}
		if($Line=~/HET\=(\S+?)\;/){$info{'HET'}=$1;}
		if($Line=~/HOM\=(\S+?)\;/){$info{'HOM'}=$1;}
		if($Line=~/NC\=(\S+?)\;/){$info{'NC'}=$1;}
		if($Line=~/DP\=(\S+?)\;/){$info{'DP'}=$1;}
		if($Line=~/VDB\=(\S+?)\;/){$info{'VDB'}=$1;}
		if($Line=~/RPB\=(\S+?)\;/){$info{'RPB'}=$1;}
		if($Line=~/AF1\=(\S+?)\;/ or $Line=~/AF\=(\S+?)\;/){$info{'AF1'}=$1;}
		if($Line=~/AC1\=(\S+?)\;/ or $Line=~/AC\=(\S+?)\;/){$info{'AC1'}=$1;}
		if($Line=~/DP4\=(\S+?)\;/){$info{'DP4'}=$1;}
		if($Line=~/MQ\=(\S+?)\;/){$info{'MQ'}=$1;}
		if($Line=~/FQ\=(\S+?)\;/){$info{'FQ'}=$1;}
		if($Line=~/PV4\=(\S+?)\;/){$info{'PV4'}=$1;}
		if($Line=~/Func.ensGene\=(\S+?)\;/){$info{'FuncENSGene'}=$1;}
		if($Line=~/Gene.ensGene\=(\S+?)\;/){$info{'GeneENSGene'}=$1;}
		if($Line=~/GeneDetail.ensGene\=(\S+?)\;/){$info{'GeneDetailENSGene'}=$1;}
		if($Line=~/ExonicFunc.ensGene\=(\S+?)\;/){$info{'ExonicFuncENSGene'}=$1;}
		if($Line=~/AAChange.ensGene\=(\S+?)\;/){$info{'AAChangeENSGene'}=$1;}
		if($Line=~/Func.knownGene\=(\S+?)\;/){$info{'FuncknownGene'}=$1;}
		if($Line=~/Gene.knownGene\=(\S+?)\;/){$info{'GeneknownGene'}=$1;}
		if($Line=~/GeneDetail.knownGene\=(\S+?)\;/){$info{'GeneDetailknownGene'}=$1;}
		if($Line=~/ExonicFunc.knownGene\=(\S+?)\;/){$info{'ExonicFuncknownGene'}=$1;}
		if($Line=~/AAChange.knownGene\=(\S+?)\;/){$info{'AAChangeknownGene'}=$1;}
		if($Line=~/MAF281\=(\S+?)[\;\s]/){$info{'MAF281'}=$1;}
		if($Line=~/ExAC_ALL\=(\S+?)\;/){$info{'ExAC_ALL'}=$1;}
		if($Line=~/esp6500siv2all\=(\S+?)\;/ or $Line=~/esp6500siv2_all\=(\S+?)\;/){$info{'esp6500siv2all'}=$1;}
		if($Line=~/avsnp144\=(\S+?)\;/){$info{'avsnp144'}=$1;}
		if($Line=~/cg69\=(\S+?)\;/){$info{'cg69'}=$1;}
		if($Line=~/avsnp142\=(\S+?)\;/){$info{'avsnp142'}=$1;}
		if($Line=~/cosmic70\=(\S+?)\;/){$info{'cosmic70'}=$1;}
		if($Line=~/clinvar20151201\=(\S+?)\;/ or $Line=~/clinvar_20150330\=(\S+?)\;/){$info{'clinvar20151201'}=$1;}
		if($Line=~/SIFT_pred\=(\S+?)\;/){$info{'SIFT_pred'}=$1;}
		if($Line=~/Polyphen2_HDIV_pred\=(\S+?)\;/){$info{'Polyphen2_HDIV_pred'}=$1;}
		if($Line=~/Polyphen2_HVAR_pred\=(\S+?)\;/){$info{'Polyphen2_HVAR_pred'}=$1;}
		if($Line=~/LRT_pred\=(\S+?)\;/){$info{'LRT_pred'}=$1;}
		if($Line=~/MutationTaster_pred\=(\S+?)\;/){$info{'MutationTaster_pred'}=$1;}
		if($Line=~/MutationAssessor_pred\=(\S+?)\;/){$info{'MutationAssessor_pred'}=$1;}
		if($Line=~/FATHMM_pred\=(\S+?)\;/){$info{'FATHMM_pred'}=$1;}
		if($Line=~/PROVEAN_pred\=(\S+?)\;/){$info{'PROVEAN_pred'}=$1;}
		if($Line=~/VEST3_score\=(\S+?)\;/){$info{'VEST3_score'}=$1;}
		if($Line=~/CADD_raw\=(\S+?)\;/){$info{'CADD_raw'}=$1;}
		if($Line=~/CADD_phred\=(\S+?)\;/){$info{'CADD_phred'}=$1;}
		if($Line=~/DANN_score\=(\S+?)\;/){$info{'DANN_score'}=$1;}
		if($Line=~/fathmm-MKL_coding_pred\=(\S+?)\;/){$info{'fathmm-MKL_coding_pred'}=$1;}
		if($Line=~/MetaSVM_pred\=(\S+?)\;/){$info{'MetaSVM_pred'}=$1;}
		if($Line=~/MetaLR_pred\=(\S+?)\;/){$info{'MetaLR_pred'}=$1;}
		if($Line=~/integrated_fitCons_score\=(\S+?)\;/){$info{'integrated_fitCons_score'}=$1;}
		if($Line=~/GERP++_RS\=(\S+?)\;/){$info{'GERP++_RS'}=$1;}
		if($Line=~/phyloP20way_mammalian\=(\S+?)\;/){$info{'phyloP20way_mammalian'}=$1;}
		if($Line=~/phastCons20way_mammalian\=(\S+?)\;/){$info{'phastCons20way_mammalian'}=$1;}
		if($Line=~/SiPhy_29way_logOdds\=(\S+?)\;/){$info{'SiPhy_29way_logOdds'}=$1;}
		if($Line=~/Interpro_domain\=(\S+?)\;/){$info{'Interpro_domain'}=$1;}
		if($Line=~/dbscSNV_ADA_SCORE\=(\S+?)\;/){$info{'dbscSNV_ADA_SCORE'}=$1;}
		if($Line=~/dbscSNV_RF_SCORE\=(\S+?)\;/){$info{'dbscSNV_RF_SCORE'}=$1;}
		if($Line=~/HRC_AF\=(\S+?)\;/){$info{'HRC_AF'}=$1;}		
		if($Line=~/HRC_non1000G_AF\=(\S+?)\;/){$info{'HRC_non1000G_AF'}=$1;}
		if($Line=~/Kaviar_AF\=(\S+?)\;/){$info{'Kaviar_AF'}=$1;}
		if($Line=~/nci60\=(\S+?)\;/){$info{'nci60'}=$1;}
		if($Line=~/MitImpact_id\=(\S+?)\;/){$info{'MitImpact_id'}=$1;}
		if($Line=~/Gene_symbol\=(\S+?)\;/){$info{'Gene_symbol'}=$1;}
		if($Line=~/OXPHOS_[cC]omplex\=(\S+?)\;/){$info{'OXPHOS_complex'}=$1;}
		if($Line=~/Ensembl_[Gg]ene_[iI][dD]\=(\S+?)\;/){$info{'Ensembl_gene_id'}=$1;}
		if($Line=~/Ensembl_[pP]rotein_[Ii][dD]\=(\S+?)\;/){$info{'Ensembl_protein_id'}=$1;}
		if($Line=~/Ensembl_transscript_id\=(\S+?)\;/){$info{'Ensembl_transcript_id'}=$1;}
		if($Line=~/Uniprot_[nN]ame\=(\S+?)\;/){$info{'Uniprot_name'}=$1;}
		if($Line=~/Uniprot_[Ii][Dd]\=(\S+?)\;/){$info{'Uniprot_id'}=$1;}
		if($Line=~/Ncbi_gene_id\=(\S+?)\;/ or $Line=~/NCBI_Gene_ID\=(\S+?)\;/){$info{'Ncbi_gene_id'}=$1;}
		if($Line=~/Ncbi_protein_id\=(\S+?)\;/ or $Line=~/NCBI_Protein_ID\=(\S+?)\;/){$info{'Ncbi_protein_id'}=$1;}
		if($Line=~/Gene_position\=(\S+?)\;/ or $Line=~/Gene_pos\=(\S+?)\;/){$info{'Gene_position'}=$1;}
		if($Line=~/AA_position\=(\S+?)\;/ or $Line=~/AA_pos\=(\S+?)\;/){$info{'AA_position'}=$1;}
		if($Line=~/AA_ref\=(\S+?)\;/){$info{'AA_ref'}=$1;}
		if($Line=~/AA_alt\=(\S+?)\;/ or $Line=~/AA_sub\=(\S+?)\;/){$info{'AA_alt'}=$1;}
		if($Line=~/Codon_substitution\=(\S+?)\;/ or $Line=~/Codon_sub\=(\S+?)\;/){$info{'Codon_substitution'}=$1;}
		if($Line=~/PhyloP_100V\=(\S+?)\;/){$info{'PhyloP_100V'}=$1;}
		if($Line=~/PhastCons_100V\=(\S+?)\;/){$info{'PhastCons_100V'}=$1;}
		if($Line=~/SiteVar\=(\S+?)\;/){$info{'SiteVar'}=$1;}
		#if($Line=~/PolyPhen2\=(\S+?)\;/ or $Line=~/PolyPhen2_pred\=(\S+?)\;/){$info{'PolyPhen2'}=$1;}
		if($Line=~/PolyPhen2_pred\=(\S+?)\;/){$info{'PolyPhen2'}=$1;}
		#if($Line=~/SIFT\=(\S+?)\;/){$info{'SIFT'}=$1;}
		if($Line=~/SIFT_pred\=(\S+?)\;/){$info{'SIFT'}=$1;}
		if($Line=~/FatHmm_pred\=(\S+?)\;/){$info{'FatHmm_pred'}=$1;}
		if($Line=~/FatHmmW\=(\S+?)\;/){$info{'FatHmmW'}=$1;}
		#if($Line=~/PROVEAN\=(\S+?)\;/){$info{'PROVEAN'}=$1;}
		if($Line=~/PROVEAN_pred\=(\S+?)\;/){$info{'PROVEAN'}=$1;}
		if($Line=~/MutationAssessor\=(\S+?)\;/ or $Line=~/MutAss_pred\=(\S+?)\;/){$info{'MutationAssessor'}=$1;}
		if($Line=~/EFIN_SP\=(\S+?)\;/ or $Line=~/EFIN_Swiss_Prot_Pred\=(\S+?)\;/){$info{'EFIN_SP'}=$1;}
		if($Line=~/EFIN_HD\=(\S+?)\;/ or $Line=~/EFIN_HumDiv_Pred\=(\S+?)\;/){$info{'EFIN_HD'}=$1;}
		if($Line=~/CADD_[pP]hred\=(\S+?)\;/){$info{'CADD_phred'}=$1;}
		#if($Line=~/CADD\=(\S+?)\;/){$info{'CADD'}=$1;}
		if($Line=~/CADD_pred\=(\S+?)\;/){$info{'CADD'}=$1;}
		if($Line=~/VEST_pvalue\=(\S+?)\;/){$info{'VEST_pvalue'}=$1;}
		if($Line=~/VEST_FDR\=(\S+?)\;/){$info{'VEST_FDR'}=$1;}
		if($Line=~/PANTHER\=(\S+?)\;/){$info{'PANTHER'}=$1;}
		if($Line=~/PhD-SNP\=(\S+?)\;/){$info{'PhD-SNP'}=$1;}
		if($Line=~/SNAP\=(\S+?)\;/){$info{'SNAP'}=$1;}
		if($Line=~/Meta-SNP\=(\S+?)\;/){$info{'Meta-SNP'}=$1;}
		if($Line=~/Meta-SNP_RI\=(\S+?)\;/){$info{'Meta-SNP_RI'}=$1;}
		if($Line=~/CAROL\=(\S+?)\;/ or $Line=~/Carol_pred\=(\S+?)\;/){$info{'CAROL'}=$1;}
		#if($Line=~/Condel\=(\S+?)\;/){$info{'Condel'}=$1;}
		if($Line=~/Condel_pred\=(\S+?)\;/){$info{'Condel'}=$1;}
		if($Line=~/COVEC_WMV_pred\=(\S+?)\;/){$info{'COVEC_WMV'}=$1;}
		if($Line=~/PolyPhen2_transf\=(\S+?)\;/ or $Line=~/PolyPhen2_pred_transf\=(\S+?)\;/){$info{'PolyPhen2_transf'}=$1;}
		if($Line=~/SIFT_transf\=(\S+?)\;/ or $Line=~/SIFT_pred_transf\=(\S+?)\;/){$info{'SIFT_transf'}=$1;}
		if($Line=~/MutationAssessor_transf\=(\S+?)\;/ or $Line=~/MutAss_pred_transf\=(\S+?)\;/){$info{'MutationAssessor_transf'}=$1;}
		if($Line=~/CHASM_pvalue\=(\S+?)\;/){$info{'CHASM_pvalue'}=$1;}
		if($Line=~/CHASM_FDR\=(\S+?)\;/){$info{'CHASM_FDR'}=$1;}
		if($Line=~/MISTIC_coevo_sites\=(\S+?)\;/){$info{'MISTIC_coevo_sites'}=$1;}
		if($Line=~/MISTIC_mean_MI_score\=(\S+?)\;/){$info{'MISTIC_mean_MI_score'}=$1;}
		if($Line=~/Variant_status\=(\S+?)\;/ or $Line=~/Status\=(\S+?)\;/){$info{'Variant_status'}=$1;}
		if($Line=~/Associated_disease\=(\S+?)\;/){$info{'Associated_disease'}=$1;}
		if($Line=~/Variant_class\=(\S+?)\;/ or $Line=~/Class_predicted\=(\S+?)\;/){$info{'Variant_class'}=$1;}
		if($Line=~/APOGEE_probN\=(\S+?)\;/ or $Line=~/Prob_N\=(\S+?)\;/){$info{'APOGEE_probN'}=$1;}
		if($Line=~/APOGEE_probP\=(\S+?)\;/ or $Line=~/Prob_P\=(\S+?)\;/){$info{'APOGEE_probP'}=$1;}
		if($Line=~/APOGEE\=(\S+?)\;/){$info{'APOGEE'}=$1;}
		
		#print line info to output txt file
		for(my $c=0;$c<7;$c++){print OUT "$lsplit[$c]\t";}
		my @lineA=("$info{'TS'}","$info{'TG'}","$info{'HmR'}","$info{'Ht'}","$info{'HmV'}","$info{'MAF'}",
		"$info{'ADP'}","$info{'WT'}","$info{'HET'}","$info{'HOM'}","$info{'NC'}","$info{'DP'}","$info{'VDB'}","$info{'RPB'}","$info{'AF1'}",
		"$info{'AC1'}","$info{'DP4'}","$info{'MQ'}","$info{'FQ'}","$info{'PV4'}",
		"$info{'FuncENSGene'}","$info{'GeneENSGene'}","$info{'GeneDetailENSGene'}","$info{'ExonicFuncENSGene'}","$info{'AAChangeENSGene'}",
		"$info{'FuncknownGene'}","$info{'GeneknownGene'}","$info{'GeneDetailknownGene'}","$info{'ExonicFuncknownGene'}","$info{'AAChangeknownGene'}",
		"$info{'MAF281'}","$info{'ExAC_ALL'}","$info{'esp6500siv2all'}","$info{'cg69'}",
		"$info{'avsnp144'}","$info{'avsnp142'}","$info{'cosmic70'}","$info{'clinvar20151201'}","$info{'SIFT_pred'}","$info{'Polyphen2_HDIV_pred'}","$info{'Polyphen2_HVAR_pred'}",
		"$info{'LRT_pred'}","$info{'MutationTaster_pred'}","$info{'MutationAssessor_pred'}","$info{'FATHMM_pred'}","$info{'PROVEAN_pred'}",
		"$info{'VEST3_score'}","$info{'CADD_raw'}","$info{'CADD_phred'}","$info{'DANN_score'}","$info{'fathmm-MKL_coding_pred'}","$info{'MetaSVM_pred'}",
		"$info{'MetaLR_pred'}","$info{'integrated_fitCons_score'}","$info{'integrated_confidence_value'}","$info{'GERP++_RS'}","$info{'phyloP20way_mammalian'}",
		"$info{'phastCons20way_mammalian'}","$info{'SiPhy_29way_logOdds'}","$info{'Interpro_domain'}","$info{'dbscSNV_ADA_SCORE'}","$info{'dbscSNV_RF_SCORE'}",
		"$info{'HRC_AF'}","$info{'HRC_non1000G_AF'}","$info{'Kaviar_AF'}","$info{'nci60'}","$info{'MitImpact_id'}","$info{'Gene_symbol'}",
		"$info{'OXPHOS_complex'}","$info{'Ensembl_gene_id'}","$info{'Ensembl_protein_id'}","$info{'Ensembl_transcript_id'}","$info{'Uniprot_name'}",
		"$info{'Uniprot_id'}","$info{'Ncbi_gene_id'}","$info{'Ncbi_protein_id'}","$info{'Gene_position'}","$info{'AA_position'}","$info{'AA_ref'}",
		"$info{'AA_alt'}","$info{'Codon_substitution'}","$info{'PhyloP_100V'}","$info{'PhastCons_100V'}","$info{'SiteVar'}","$info{'PolyPhen2'}","$info{'SIFT'}",
		"$info{'FatHmm_pred'}","$info{'FatHmmW'}","$info{'PROVEAN'}","$info{'MutationAssessor'}","$info{'EFIN_SP'}","$info{'EFIN_HD'}","$info{'CADD_phred'}",
		"$info{'CADD'}","$info{'VEST_pvalue'}","$info{'VEST_FDR'}","$info{'PANTHER'}","$info{'PhD-SNP'}","$info{'SNAP'}","$info{'Meta-SNP'}",
		"$info{'Meta-SNP_RI'}","$info{'CAROL'}","$info{'Condel'}","$info{'COVEC_WMV'}","$info{'PolyPhen2_transf'}","$info{'SIFT_transf'}",
		"$info{'MutationAssessor_transf'}","$info{'CHASM_pvalue'}","$info{'CHASM_FDR'}","$info{'MISTIC_coevo_sites'}","$info{'MISTIC_mean_MI_score'}",
		"$info{'Variant_status'}","$info{'Associated_disease'}","$info{'Variant_class'}","$info{'APOGEE_probN'}","$info{'APOGEE_probP'}","$info{'APOGEE'}");
		for(my $c1=0;$c1<scalar(@lineA);$c1++){print OUT "$lineA[$c1]\t";}
		for(my $c2=8;$c2<scalar(@lsplit);$c2++){my @genosplit=split(/:/,$lsplit[$c2]); print OUT "\'$genosplit[0]\t";}
		for(my $c2=8;$c2<scalar(@lsplit);$c2++){print OUT "$lsplit[$c2]\t";}
		print OUT "END\n";
}
close INPUT2;
close OUT;
exit;
