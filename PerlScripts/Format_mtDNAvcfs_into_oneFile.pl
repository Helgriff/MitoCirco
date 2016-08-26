#!/usr/bin/perl -w

#Program to put homoplasmic (HF>0.9) mtDNA variants into format for Circos plot data files
use strict;
use warnings;

my($path1,$path2,$ID2)=@ARGV;

my $outfile = $path2."/Varsmt.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path2."/Varsnc.txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";
my $outfile4 = $path2."/Varsmtonly.txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";

#VVCF_FILE="${VARSCAN_OUT_DIR}/${SAMPLE_ID}_varscan_nodups_rCRSplus.vcf"
my @DirContent=`ls $path1`;
foreach my $folder (@DirContent){
	chomp $folder;
if($folder=~/${ID2}_varscan_nodups_hg38.vcf/){
	open INPUT, $path1."/".$folder or die "Cannot open $folder\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[9]=~/\%/){$lsplit[9]=~s/\%\S+//; $lsplit[9]=~s/\S+\://;} #get %varfreq from vcf file
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		my $freq=$lsplit[9]/100;
		if($lsplit[0]=~/[1-9,X,Y]/){print OUT2 "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$freq\tcolor=red\n";}
		if($lsplit[0]=~/M/ and $freq>0.9){print OUT "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$freq\tcolor\=vdred\n";}
		}
close INPUT;
}
if($folder=~/${ID2}_varscan_nodups_hg38plus.vcf/){
	open INPUT, $path1."/".$folder or die "Cannot open $folder\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[9]=~/\%/){$lsplit[9]=~s/\%\S+//; $lsplit[9]=~s/\S+\://;} #get %varfreq from vcf file
		if($lsplit[0]=~/[1-9,X,Y]/){next loop;}
		if($lsplit[1]>200 and $lsplit[1]<16400){next loop;}
		my $freq=$lsplit[9]/100;
		if($lsplit[0]=~/M/ and $freq>0.9){print OUT "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$freq\tcolor\=vdred\n";}
		}
close INPUT;
}
if($folder=~/${ID2}_varscan_nodups_rCRS.vcf/){
	open INPUT, $path1."/".$folder or die "Cannot open $folder\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[9]=~/\%/){$lsplit[9]=~s/\%\S+//; $lsplit[9]=~s/\S+\://;} #get %varfreq from vcf file
		my $freq=$lsplit[9]/100;
		if($lsplit[0]=~/M/ and $freq>0.9){print OUT4 "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$freq\tcolor\=vdblue\n";}
		}
close INPUT;
}
}
close OUT;
close OUT2;
close OUT4;
exit;		
