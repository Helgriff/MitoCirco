#!/usr/bin/perl -w
use strict;
use warnings;

#Program to extract read depths for hg38+rCRS and rCRSonly pileup files

my ($path1, $path2, $ID2, $Type)=@ARGV;

my $outfile = $path2."/Depthmt.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path2."/Depthnc.txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";
my $outfile4 = $path2."/Depthmtonly.txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";

my @dircont=`ls $path1`;
foreach my $file (@dircont){
	chomp $file;
if($file =~ /${ID2}\S+hg38.pileup/){
open INPUT, $path1."/".$file or die "Cannot open $file\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		#if($lsplit[3]<2){next loop;}
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		if($lsplit[0]=~/M/){print OUT "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$lsplit[3]\tcolor\=orange\n"; next loop;}
		if($lsplit[0]=~/[1-9,X,Y]/){print OUT2 "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$lsplit[3]\tcolor=vdblue\n"; next loop;}
		}#while loop
close INPUT;
close OUT2;
}
if($file =~ /${ID2}\S+hg38plus.pileup/){
open INPUT, $path1."/".$file or die "Cannot open $file\n";
	loop3: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]>200 and $lsplit[1]<16400){next loop3;}
		if($lsplit[0]=~/[1-9,X,Y]/){next loop3;}
		if($lsplit[0]=~/M/){print OUT "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$lsplit[3]\tcolor\=orange\n"; next loop3;}
		}#while loop
close INPUT;
close OUT;
}
if($file =~ /${ID2}\S+rCRS.pileup/){
open INPUT, $path1."/".$file or die "Cannot open $file\n";
	loop2: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]=~/M/){print OUT4 "hs$lsplit[0]\t$lsplit[1]\t$lsplit[1]\t$lsplit[3]\tcolor\=vdorange\n";}
		}
close INPUT;
close OUT4;
}
}

#Average coverage per 50Kb window if type==Genome or Exome
my %AvNuc;
my $count=0; #upto 50000bp count
my $window=0; #50Kb window count
my $chr="NA";
if($Type=~/Genome/ or $Type=~/Exome/){
open INPUT3, $outfile2 or die "Cannot open $outfile2\n";
	loop3: while (<INPUT3>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if($lsplit[0]=~/\_\S+/){next loop3;}
		if($lsplit[0] ne $chr){$count=0; $window=0;} #re-initialise $count and $window to 0 if previous chrom average finished mid-way through 30Kb window
		$chr=$lsplit[0];
		if(!exists $AvNuc{$chr}[$window]{'spos'}){$AvNuc{$chr}[$window]{'spos'}=$lsplit[1];}
		if(!exists $AvNuc{$chr}[$window]{'AvDepth'}){$AvNuc{$chr}[$window]{'AvDepth'}=0;}
		my $avg = ( $lsplit[3] + ($AvNuc{$chr}[$window]{'AvDepth'} * $count) ) / ( $count + 1 );
		$AvNuc{$chr}[$window]{'AvDepth'}=$avg;
		$count++;
		if($count==50000){$window++; $count=0;}
	}
close INPUT3;
my $outfile3 = $path2."/Depthnc.txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
foreach my $ch (sort keys %AvNuc){
	for (my $w=0; $w<(scalar @{$AvNuc{$ch}}); $w++){
		print OUT3 "$ch\t$AvNuc{$ch}[$w]{'spos'}\t$AvNuc{$ch}[$w]{'spos'}\t$AvNuc{$ch}[$w]{'AvDepth'}\tcolor=vdblue\n";
		}
	}
close OUT3;
}
exit;
