#!/usr/bin/perl -w

## Program to put all MitoSeek heteroplasmy predictions (mito1_heteroplasmy.txt files) into one file with ID labels
## Summary Report files of per Sample and per mtDNA base position Significant Heteroplasmy counts
use strict;
use warnings;

## Path to a single directory containing all MitoSeek output "mito1_heteroplasmy.txt" files
#my $path1="/home/nhrg/WORKING_DATA/SourceBio/Reruns_2876/heteroplasmy_with_baseline_rate_wgt15";
my $path1="/home/nhrg/WORKING_DATA/SourceBio/HETEROPLASMY_MSKpp";
my @DirContent=`ls $path1`;
##
my $outfile = $path1."/Heteroplasmy_Results_with_FisherPval_from_perPos_T2_Baseline_Rate.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path1."/Heteroplasmy_Sig_Results_with_FisherPval_from_perPos_T2_Baseline_Rate.txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";
my $outfile3 = $path1."/Heteroplasmy_sig_Count_Per_Position_T2.txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
my $outfile4 = $path1."/Heteroplasmy_sig_Count_Per_Sample_T2.txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";

my $filecount=0;
my %Counts;
my %CountsS;

## Read variants into %hets
foreach my $file (@DirContent){
	chomp $file;
if($file=~/(\S+)_nodups_hg38_mitoSK_heteroplasmy.txt/){
	my $ID=$1;
	$filecount++;
	%CountsS=();
	open INPUT, $path1."/".$file or die "Cannot open $file\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#chr/){
			if($filecount==1){print OUT "ID\t$Line\n";print OUT2 "ID\t$Line\n";print OUT4 "ID\tNO.HET.0\%\tNO.HET.1\%\tNO.HET.2\%\tNO.HET.4\%\tNO.HET.10\%\tTOT_POS\t\%HET.POS.\>1\%HF\tNO.HET.1\%_NoFishers\n";}
			$CountsS{'0p'}=0;
			$CountsS{'1pNS'}=0;
			$CountsS{'1p'}=0;
			$CountsS{'2p'}=0;
			$CountsS{'4p'}=0;
			$CountsS{'10p'}=0;
			next loop;
			}
		my @lsplit=split(/\t/,$Line);
		print OUT "$ID\t$Line\n";
		
		my $adjP=sprintf("%.3f",$lsplit[27]);
		my $het=sprintf("%.3f",$lsplit[11]);
		
		#print "Pre_adjP:$lsplit[27]\tadjP: $adjP\tPre_het: $lsplit[11]\thet: $het\n";
		
		if($adjP<0.05 and $het>0.01){print OUT2 "$ID\t$Line\n";} #if multiple testing corrected Fisher pvalue < 0.05 and heteroplasmy >1%
		
		if(!exists $Counts{$lsplit[1]}){$Counts{$lsplit[1]}{'1pNS'}=0;$Counts{$lsplit[1]}{'0p'}=0;$Counts{$lsplit[1]}{'1p'}=0;$Counts{$lsplit[1]}{'2p'}=0;$Counts{$lsplit[1]}{'4p'}=0;$Counts{$lsplit[1]}{'10p'}=0;}
		if($het>0.01){$Counts{$lsplit[1]}{'1pNS'}++; $CountsS{'1pNS'}++;} #if HF >1% and no fishers sig filter
		if($adjP<0.05){$Counts{$lsplit[1]}{'0p'}++; $CountsS{'0p'}++;}	 #if fishers adjusted pval<0.05 for any %HF
		if($het>0.01 and $adjP<0.05){$Counts{$lsplit[1]}{'1p'}++; $CountsS{'1p'}++;} #if multiple testing corrected Fisher pvalue < 0.05 and heteroplasmy >1%
		if($het>0.02 and $adjP<0.05){$Counts{$lsplit[1]}{'2p'}++; $CountsS{'2p'}++;}
		if($het>0.04 and $adjP<0.05){$Counts{$lsplit[1]}{'4p'}++; $CountsS{'4p'}++;}
		if($het>0.10 and $adjP<0.05){$Counts{$lsplit[1]}{'10p'}++; $CountsS{'10p'}++;}
		}
		close INPUT;
		my $pcnt_Het=($CountsS{'1p'}/16569)*100;
		print OUT4 "$ID\t$CountsS{'0p'}\t$CountsS{'1p'}\t$CountsS{'2p'}\t$CountsS{'4p'}\t$CountsS{'10p'}\t16569\t$pcnt_Het\t$CountsS{'1pNS'}\n";
}
}
close OUT;
close OUT2;

print OUT3 "POS\tNO.HET.0\%\tNO.HET.1\%\tNO.HET.2\%\tNO.HET.4\%\tNO.HET.10\%\tTOT_SAMPLES\t\%HET.SAMPLES\tNO.HET.1\%.NoFishers\n";
foreach my $p (sort {$a<=>$b} keys %Counts){
my $pcnt_Tot=($Counts{$p}{'0p'}/$filecount)*100;
print OUT3 "$p\t$Counts{$p}{'0p'}\t$Counts{$p}{'1p'}\t$Counts{$p}{'2p'}\t$Counts{$p}{'4p'}\t$Counts{$p}{'10p'}\t$filecount\t$pcnt_Tot\t$Counts{$p}{'1pNS'}\n";
}
close OUT3;
exit;		
