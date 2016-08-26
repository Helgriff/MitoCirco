#!/usr/bin/perl -w

#Program to get per sample %heteroplasmy counts into Haplogroup specific files

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
my %hets;
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

my $outfile3 = $path1."/Heteroplasmy_Counts_per_Haplogroup_chrM_".$NoSamples.".txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
my $outfile4 = $path1."/Heteroplasmy_Percentage_per_Haplogroup_chrM_".$NoSamples.".txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";

###Get %heteroplasmies per Haplogroup
foreach my $h (keys %Haps){

%hets=();

floop2:foreach my $ID2 (keys %IDs){
	#initialise %hets per file
	if($IDs{$ID2}!~/^$h$/){next floop2;}
	for(my $c=1;$c<=16569;$c++){
		$hets{$ID2}{$c}=0;
		if(!exists $counts{$c}{$h}{'10_90'}){$counts{$c}{$h}{'10_90'}=0;}
		if(!exists $counts{$c}{$h}{'2_98'}){$counts{$c}{$h}{'2_98'}=0;}
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
		$hets{$ID2}{$lsplit[1]}=$lsplit[9];
		if($lsplit[9]>10 and $lsplit[9]<90){$counts{$lsplit[1]}{$h}{'10_90'}++;}
		if(($lsplit[9]>2 and $lsplit[9]<=10) or ($lsplit[9]>=90 and $lsplit[9]<98)){$counts{$lsplit[1]}{$h}{'2_98'}++;}
		}
		close INPUT2;
	#hg38 rCRSplus vcf file
	my $file3 = $path1."/".$h."/".$ID2.$Vcf_suffix2;	
	open INPUT2, $file3 or die "Cannot open $file3\n";
	loop3: while (<INPUT2>){
		my $Line=$_;
		if($Line=~/\#/){next loop3;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop3;} #chrM only
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		if($pp[1]>=200 and $pp[1]<=16400){next loop3;} #use rCRS alignment for these positions
		$lsplit[1]=$pp;
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		$hets{$ID2}{$lsplit[1]}=$lsplit[9];
		if($lsplit[9]>10 and $lsplit[9]<90){$counts{$lsplit[1]}{$h}{'10_90'}++;}
		if(($lsplit[9]>2 and $lsplit[9]<=10) or ($lsplit[9]>=90 and $lsplit[9]<98)){$counts{$lsplit[1]}{$h}{'2_98'}++;}
		}
		close INPUT2;
} #foreach ID
}

#print heteroplasmy counts to file3
print OUT3 "rCRS-base-pos";
foreach my $h (sort keys %Haps){print OUT3 "\t$h\t$h";}
print OUT3 "\tTotal2-98\tTotal10-90\n";
for(my $c=1;$c<=16569;$c++){
	print OUT3 "$c";
	my $tot1=0;
	my $tot2=0;
	foreach my $h (sort keys %{$counts{$c}}){
		print OUT3 "\t$counts{$c}{$h}{'2_98'}\t$counts{$c}{$h}{'10_90'}";
		$tot1+=$counts{$c}{$h}{'2_98'};
		$tot2+=$counts{$c}{$h}{'10_90'};
	}
	print OUT3 "\t$tot1\t$tot2\n";
}
close OUT3;

#print heteroplasmic percentages to file4
print OUT4 "rCRS-base-pos";
foreach my $h (sort keys %Haps){print OUT4 "\t$h\t$h";}
print OUT4 "\tTotal\tTotal\n";
for(my $c=1;$c<=16569;$c++){
	print OUT4 "$c";
	my $tot1=0;
	my $tot2=0;
	foreach my $h (sort keys %{$counts{$c}}){
		my $percnt=($counts{$c}{$h}{'2_98'}/$NoSamples)*100;
		my $percnt2=($counts{$c}{$h}{'10_90'}/$NoSamples)*100;
		print OUT4 "\t$percnt\t$percnt2";
		$tot1+=$counts{$c}{$h}{'2_98'};
		$tot2+=$counts{$c}{$h}{'10_90'};
		}
	my $totpercnt=($tot1/$NoSamples)*100;
	my $totpercnt2=($tot2/$NoSamples)*100;
	print OUT4 "\t$totpercnt\t$totpercnt2\n";
}
close OUT4;

#Output Haplogroups and file/ID counts	
print "Haplogroup\tCount\n";
foreach my $h (sort keys %Haps){
	print "$h\t$Haps{$h}\n";
}

exit;		
