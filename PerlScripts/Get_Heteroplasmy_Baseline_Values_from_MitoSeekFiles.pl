#!/usr/bin/perl -w

## Program to determine the baseline heteroplasmy rate per mtDNA position from multiple MitoSeek mito1_heteroplasmy.txt files
use strict;
use warnings;

my $path1="/home/nhrg/WORKING_DATA/SourceBio/HETEROPLASMY_MSKpp";
my @DirContent=`ls $path1`;
my $outfile = $path1."/Heteroplasmy_Baseline_Rate_using_BaselineScript_output_wgtuciT-2_5180xSB.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my %hets;
my %ref;
my $filecount=0;
my $wgt=15; #recalculated below ... $wgt=$filecount/2 

## Read variants into %hets
foreach my $file (@DirContent){
	chomp $file;
if($file=~/\S+_hg38_mitoSK_heteroplasmy.txt/){
	$filecount++;
	open INPUT, $path1."/".$file or die "Cannot open $file\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		if(!exists $ref{$lsplit[1]}){$ref{$lsplit[1]}=$lsplit[2];}
		if(!exists $hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}){
			$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'MJC'}=0;
			$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'MNC'}=0;
			$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'CIU'}=0;
			$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'CNT'}=0;
			}
		$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'MJC'}+=$lsplit[16];
		$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'MNC'}+=$lsplit[17];
		$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'CIU'}+=$lsplit[13]; #heteroplasmy upper 95% CI
		$hets{$lsplit[1]}{$lsplit[14]}{$lsplit[15]}{'CNT'}++;
	}
	close INPUT;
}
}

$wgt=$filecount/2;

## Print out results per mtDNA position
print OUT "\#CHROM\tPOS\tREF\tMAJOR\tMINOR\tTOT_MAJ_AL\tTOT_MIN_AL\tAVERAGE_HET\tNO_SAMPLES\tBASELINE_HET\twgtBASELINE_HET\tuciBASELINE_HET\n";
foreach my $p (sort {$a<=>$b} keys %hets){
	foreach my $j (sort keys %{$hets{$p}}){
		foreach my $n (sort keys %{$hets{$p}{$j}}){
			my $AvHet=$hets{$p}{$j}{$n}{'MNC'}/($hets{$p}{$j}{$n}{'MJC'}+$hets{$p}{$j}{$n}{'MNC'});
			my $BaselineHet=($AvHet*$hets{$p}{$j}{$n}{'CNT'})/$filecount;
			my $BaselineHetwgt=($AvHet*$hets{$p}{$j}{$n}{'CNT'}*$wgt)/($filecount+($hets{$p}{$j}{$n}{'CNT'}*($wgt-1)));
			my $BaselineHetuci=($hets{$p}{$j}{$n}{'CIU'}*$wgt)/($filecount+($hets{$p}{$j}{$n}{'CNT'}*($wgt-1)));
			print OUT "chrM\t$p\t$ref{$p}\t$j\t$n\t$hets{$p}{$j}{$n}{'MJC'}\t$hets{$p}{$j}{$n}{'MNC'}\t$AvHet\t$hets{$p}{$j}{$n}{'CNT'}\t$BaselineHet\t$BaselineHetwgt\t$BaselineHetuci\n";
		}
	}
}
close OUT;

exit;		
