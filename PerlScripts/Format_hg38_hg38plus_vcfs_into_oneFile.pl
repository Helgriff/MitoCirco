#!/usr/bin/perl -w

#Program to combine hg38 and hg38plus vcfs into one file with rCRS (hg38 positions)
use strict;
use warnings;

my($path1,$path2,$vcf1,$vcf2,$sampleID)=@ARGV;

#my $path1="/home/nhrg/WORKING_DATA/SourceBio/BAMs/4028/VCFs";
#my $path2="/home/nhrg/WORKING_DATA/SourceBio/BAMs/4028/VCFs";
#my $vcf1="4028_hg38_SourceBio_Q25_Bcftools13_hg38_noIndel.vcf";
#my $vcf2="4028_hg38plus_SourceBio_Q25_Bcftools13_hg38_rCRS8330_noIndel.vcf";
#my $sampleID="4028_hg38";

my $outfile = $path1."/../".$sampleID."_Merge_SourceBio_Q25_Bcftools13_hg38_combined.vcf";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";

open INPUT, $path2."/".$vcf2 or die "Cannot open $vcf2\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){print OUT "$Line\n"; next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]=~/[1-9,X,Y]/){next loop;}
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]>200){next loop;}
		if($lsplit[0]=~/M/){
			print OUT "chr$lsplit[0]\t$lsplit[1]";
			for(my $c=2;$c<scalar(@lsplit);$c++){
				print OUT "\t$lsplit[$c]";
				}
				print OUT "\n";
			}
		}
close INPUT;

open INPUT, $path1."/".$vcf1 or die "Cannot open $vcf1\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		if($lsplit[0]=~/M/){print OUT "$Line\n";}
		}
close INPUT;

open INPUT, $path2."/".$vcf2 or die "Cannot open $vcf2\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]=~/[1-9,X,Y]/){next loop;}
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]<16400){next loop;}
		if($lsplit[0]=~/M/){
			print OUT "chr$lsplit[0]\t$lsplit[1]";
			for(my $c=2;$c<scalar(@lsplit);$c++){
				print OUT "\t$lsplit[$c]";
				}
				print OUT "\n";
			}
		}
close INPUT;
close OUT;
exit;		
