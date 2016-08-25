#!/usr/bin/perl -w

#Program to get per sample Homoplasmic Variant counts into Haplogroup specific files

use strict;
use warnings;

#define variables
my $NoSamples=2876;
my $path1="/home/nhrg/WORKING_DATA/SourceBio/VCFs"; ##path to directory containing multiple VCF files
my $HapIDfile=$path1."/SB_MajorHG_2876_Feb2016.txt"; ##tab delim text file with column1 containing bam file/sample IDs and Column2 lists Major mtDNA haplogroup of sample
my $Vcf_suffix="_varscan_nodups_hg38.vcf";
my $Vcf_suffix2="_varscan_nodups_hg38plus.vcf";
my %IDs;
my %Haps;
my @DirContent=`ls $path1`;
my %counts;

#Read ID/Haplogroup file into %
open INPUT2, $HapIDfile or die "Cannot open $HapIDfile\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if(!exists $IDs{$lsplit[0]}){$IDs{$lsplit[0]}=$lsplit[1];} #key=ID,value=Haplogroup
		if(!exists $Haps{$lsplit[1]}){$Haps{$lsplit[1]}=0; 
		`mkdir $path1/$lsplit[1]`;
		}
		$Haps{$lsplit[1]}++;
}
close INPUT2;

#Move Files into per haplogroup directories
foreach my $file (@DirContent){
		chomp($file);
		if($file=~/(\S+)$Vcf_suffix/){
		my $id=$1;
		if(exists $IDs{$id}){`mv "$path1/$file" "$path1/$IDs{$id}/"`;}
		}
		if($file=~/(\S+)$Vcf_suffix2/){
		my $id=$1;
		if(exists $IDs{$id}){`mv "$path1/$file" "$path1/$IDs{$id}/"`;}
		}
}

#Create Output Files
my $outfile3 = $path1."/Homoplasmic_Variant_Counts_per_Haplogroup_chrM_".$NoSamples.".txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
my $outfile4 = $path1."/Homoplasmic_Variant_Percentage_per_Haplogroup_chrM_".$NoSamples.".txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";

###Create %hets per Haplogroup
foreach my $h (keys %Haps){
floop2:foreach my $ID2 (keys %IDs){
	#initialise %hets per file
	if($IDs{$ID2}!~/^$h$/){next floop2;}
	for(my $c=1;$c<=16569;$c++){
		if(!exists $counts{$c}{$h}{'90plus'}){$counts{$c}{$h}{'90plus'}=0;}
		}
	#normal rCRS vcf file
	my $file3 = $path1."/".$h."/".$ID2.$Vcf_suffix;	
	open INPUT2, $file3 or die "Cannot open $file3\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		if($Line=~/\#/){next loop2;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop2;} #chrM only
		if($lsplit[1]<200 or $lsplit[1]>16400){next loop2;} #use rCRSplus alignment for these positions
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		if($lsplit[9]>=90){$counts{$lsplit[1]}{$h}{'90plus'}++;}
		}
		close INPUT2;
	#plus 8260bp rCRS vcf file
	my $file4 = $path1."/".$h."/".$ID2.$Vcf_suffix2;	
	open INPUT4, $file4 or die "Cannot open $file4\n";
	loop4: while (<INPUT4>){
		my $Line=$_;
		if($Line=~/\#/){next loop4;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop4;} #chrM only
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		if($pp[1]>=200 and $pp[1]<=16400){next loop4;} #use rCRS alignment for these positions
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		if($lsplit[9]>=90){$counts{$pp}{$h}{'90plus'}++;}
		}
		close INPUT4;
} #foreach ID
}#end of per Haplogroup outfile loop

#print homoplasmic counts to file3
print OUT3 "rCRS-base-pos";
foreach my $h (sort keys %Haps){print OUT3 "\t$h";}
print OUT3 "\tTotal\n";
for(my $c=1;$c<=16569;$c++){
	print OUT3 "$c";
	my $tot1=0;
	foreach my $h (sort keys %{$counts{$c}}){
		print OUT3 "\t$counts{$c}{$h}{'90plus'}";
		$tot1+=$counts{$c}{$h}{'90plus'};
		}
	print OUT3 "\t$tot1\n";
}
close OUT3;

#print homoplasmic percentages to file4
print OUT4 "rCRS-base-pos";
foreach my $h (sort keys %Haps){print OUT4 "\t$h";}
print OUT4 "\tTotal\n";
for(my $c=1;$c<=16569;$c++){
	print OUT4 "$c";
	my $tot1=0;
	foreach my $h (sort keys %{$counts{$c}}){
		my $percnt=($counts{$c}{$h}{'90plus'}/$NoSamples)*100;
		print OUT4 "\t$percnt";
		$tot1+=$counts{$c}{$h}{'90plus'};
		}
	my $totpercnt=($tot1/$NoSamples)*100;
	print OUT4 "\t$totpercnt\n";
}
close OUT4;

#Output Haplogroups and file/ID counts	
print "Haplogroup\tCount\n";
foreach my $h (sort keys %Haps){
	print "$h\t$Haps{$h}\n";
}

exit;		
