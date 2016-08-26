#!/usr/bin/perl -w

#Program to convert *mtDNA.sam files into circos 'links' files
use strict;
use warnings;

my($path1,$path2,$ID2,$Q)=@ARGV;

my $outfile = $path2."/Linkncmt_".$ID2.".txt"; #split pair hg38-rCRS
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path2."/Linknc_".$ID2.".txt";  #hg38 preferential, so use rCRS only to find rCRS location
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";

my %readnames;
my %unique;
my %unique2;
#my $pathid="NA";
#my @DirContent=`ls $path1`;

my $folder=$path1."/".$ID2."_hg38.sam";
open INPUT, $folder or die "Cannot open $folder\n";
	loop: while (<INPUT>){
		my $Line=$_;
		if($Line=~/^\#/){next loop;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if($lsplit[4]<$Q){next loop;} #Qual >$Q filter
		$lsplit[2]=~s/chr//;
		$lsplit[6]=~s/chr//;
		if(($lsplit[2]=~/^[1-9XY]$/ and $lsplit[6]=~/\=/) or ($lsplit[2]=~/^[123][0-9]$/ and $lsplit[6]=~/\=/)){ #add to %hg38 only IDs for chrs 1-9,X,Y or chrs 10-39
				if(!exists $readnames{$lsplit[0]}{$lsplit[2]}){
				$readnames{$lsplit[0]}{$lsplit[2]}=$lsplit[3];
				}
				next loop;
				}
		if($lsplit[6]=~/\=/ and $lsplit[2]=~/M/){next loop;} #chrM only alignments
		if($lsplit[6]!~/M/ and $lsplit[2]!~/M/){next loop;} #excludes alignments to two different nuclear chrs which are not chrM
		#unless loop should exclude all chr6_GL000252v2_alt type alignments	
		#the remaining unique entries - should only be mixed mtDNA and nuclear alignments!!
		unless($lsplit[2]=~/[0-9][0-9][0-9]/ or $lsplit[6]=~/[0-9][0-9][0-9]/){
			if(!exists ($unique{$lsplit[2]}{$lsplit[3]}{$lsplit[6]}{$lsplit[7]}) and (!exists $unique{$lsplit[6]}{$lsplit[7]}{$lsplit[2]}{$lsplit[3]})){
			print OUT "hs$lsplit[2]\t$lsplit[3]\t$lsplit[3]\ths$lsplit[6]\t$lsplit[7]\t$lsplit[7]\tcolor\=blue\n";	
			} #if
		} #unless
	} #while loop
close INPUT;
$folder=$path1."/".$ID2."_hg38plus.sam";
open INPUT, $folder or die "Cannot open $folder\n";
	loop2: while (<INPUT>){
		my $Line=$_;
		if($Line=~/^\#/){next loop2;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if($lsplit[4]<$Q){next loop2;} #Qual >$Q filter
		$lsplit[2]=~s/chr//;
		$lsplit[6]=~s/chr//;
		if(($lsplit[2]=~/^[1-9XY]$/ and $lsplit[6]=~/\=/) or ($lsplit[2]=~/^[123][0-9]$/ and $lsplit[6]=~/\=/)){ #add to %hg38 only IDs for chrs 1-9,X,Y or chrs 10-39
				if(!exists $readnames{$lsplit[0]}{$lsplit[2]}){
				$readnames{$lsplit[0]}{$lsplit[2]}=$lsplit[3];
				}
				next loop2;
				}
		if($lsplit[6]=~/\=/ and $lsplit[2]=~/M/){next loop2;} #chrM only alignments
		if($lsplit[6]!~/M/ and $lsplit[2]!~/M/){next loop2;} #excludes alignments to two different nuclear chrs which are not chrM
		#unless loop should exclude all chr6_GL000252v2_alt type alignments	
		#the remaining unique entries - should only be mixed mtDNA and nuclear alignments!!
		unless($lsplit[2]=~/[0-9][0-9][0-9]/ or $lsplit[6]=~/[0-9][0-9][0-9]/){
			if($lsplit[2]=~/M/){
			my $pp=$lsplit[3]+8260; #convert positions of rCRSplus back to correct 1-16569
			if($pp>16569){$pp=$lsplit[3]-8309;} #convert positions of rCRSplus back to correct 1-16569
			$lsplit[3]=$pp;
			}
			if($lsplit[6]=~/M/){
			my $pp=$lsplit[7]+8260; #convert positions of rCRSplus back to correct 1-16569
			if($pp>16569){$pp=$lsplit[7]-8309;} #convert positions of rCRSplus back to correct 1-16569
			$lsplit[7]=$pp;
			}
			if(!exists ($unique{$lsplit[2]}{$lsplit[3]}{$lsplit[6]}{$lsplit[7]}) and (!exists $unique{$lsplit[6]}{$lsplit[7]}{$lsplit[2]}{$lsplit[3]})){
			print OUT "hs$lsplit[2]\t$lsplit[3]\t$lsplit[3]\ths$lsplit[6]\t$lsplit[7]\t$lsplit[7]\tcolor\=blue\n";	
			} #if
		} #unless
	} #while loop
close INPUT;
close OUT;

my $folder2=$path1."/".$ID2."_rCRS.sam";
open INPUT2, $folder2 or die "Cannot open $folder2\n";
	loop3: while (<INPUT2>){
		my $Line=$_;
		if($Line=~/^\#/){next loop3;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if($lsplit[4]<$Q){next loop3;} #Qual >$Q filter
		$lsplit[2]=~s/chr//;
		
		if(exists $readnames{$lsplit[0]}){
		foreach my $ch (keys %{$readnames{$lsplit[0]}}){	
		if(!exists $unique2{$lsplit[2]}{$lsplit[3]}{$ch}{$readnames{$lsplit[0]}{$ch}}){
		print OUT2 "hs$lsplit[2]\t$lsplit[3]\t$lsplit[3]\ths$ch\t$readnames{$lsplit[0]}{$ch}\t$readnames{$lsplit[0]}{$ch}\tcolor\=lgreen\n";
			}
		}
		}
	}
close INPUT2;
close OUT2;

exit;		
