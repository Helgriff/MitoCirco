#!/usr/bin/perl -w

# Program to extract genotypes and read depths (freq alt allele) per mtDNA variant from multicalled vcf file
# print files of variant genotypes and alt allele frequencies

use strict;
use warnings;

my($path1,$file,$sampleID,$Q,$refbuild)=@ARGV;

#my $sampleID="4028_hg38";
#my $Q=25;
#my $refbuild="hg38";
#my $path1="/users/nhrg/lustre/SourceBioMito/VCFs";
#my $file=$sampleID."_SourceBio_Q".$Q."_Bcftools13_hg38_noIndel_combined.hg38_multianno.vcf";

my $GTfield=0;
my $ADfield=4;

my $outfile2 = $path1."/".$sampleID."_Merge_SourceBio_Q".$Q."_Bcftools13_combined.vcf_genos";
my $outfile3 = $path1."/".$sampleID."_Merge_SourceBio_Q".$Q."_Bcftools13_combined.vcf_altfreq";

open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
	
open INPUT, $path1."/".$file or die "Cannot open $file\n";
my @ids=();
loop: while (<INPUT>){
	my $Line=$_;
	chomp $Line;
	if($Line=~/\#CHROM/){print OUT2 "$Line\n"; print OUT3 "$Line\n";}
	if($Line=~/\#/){next loop;}
	my @lsplit=();
	if($Line=~/^chr/){@lsplit=split(/\t/,$Line);}
	
	for(my $a=0;$a<8;$a++){
		print OUT2 "$lsplit[$a]\t";
		print OUT3 "$lsplit[$a]\t";
		}
	
	## locate the 'GT' and 'AD' info fields, which differs depending on variant caller
	my @format=split(/\:/,$lsplit[8]);
	for(my $d=0;$d<scalar(@format);$d++){
		if($format[$d]=~/^GT$/){$GTfield=$d;}
		if($format[$d]=~/^AD$/){$ADfield=$d;}
		}
		
		print OUT2 "$lsplit[8]";
		print OUT3 "$lsplit[8]";
		
	## for multi sample vcfs
	for(my $c=9;$c<scalar(@lsplit);$c++){
		my @info=split(/\:/,$lsplit[$c]);
		my $genot=$info[$GTfield];
		my $aldep=$info[$ADfield];
		print OUT2 "\t$genot";
		my @af=split(/\,/,$aldep);
		my $altfreq=0;
		unless($af[0]==0 and $af[1]==0){$altfreq=$af[1]/($af[0]+$af[1]);}
		print OUT3 "\t$altfreq";
		}#for each GT:DP:etc multisample call

	print OUT2 "\n";
	print OUT3 "\n";
}
close INPUT;
close OUT2;
close OUT3;

exit;		
