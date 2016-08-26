#!/usr/bin/perl -w

#Program to use all *mtDNA.pileup files to report chrM positions that are/aren't adequately covered

use strict;
use warnings;

my($path1,$prefix,$Q,$PCNT_HOMO,$BatchID)=@ARGV;

my $outfile = $path1."/ChrM_pileup_position_QC_".$BatchID.".txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";

my @DirContent=`ls $path1`;
my %covs;
#initialise %covs per position
for(my $c=1;$c<=16569;$c++){
	$covs{$c}{'Total'}=0;
	$covs{$c}{'100fold'}=0;
	$covs{$c}{'5fold'}=0;
	}
	
###Get coverage depths
floop:foreach my $file (@DirContent){
	chomp $file;
if($file=~/(\S+hg38.pileup)/){
	#my $ID=$1;
	#my $file2 = $path1."/".$ID."_nodups_".$Q."_hg38.pileup";	
	my $file2 = $file;
	open INPUT, $file2 or die "Cannot open $file2\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop;} #chrM only
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		if($lsplit[3]>=5){$covs{$lsplit[1]}{'5fold'}++;}
		if($lsplit[3]>=100){$covs{$lsplit[1]}{'100fold'}++;}
		$covs{$lsplit[1]}{'Total'}++;
		}
	close INPUT;
	}
	
	if($file=~/(\S+hg38plus.pileup)/){
	#my $file5 = $path1."/".$file."/coverage/".$ID."_nodups_".$Q."_hg38plus.pileup";	
	my $file5 = $file;
	open INPUT, $file5 or die "Cannot open $file5\n";
	loop3: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop3;} #chrM only
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]>200 and $lsplit[1]<16400){next loop3;}
		if($lsplit[3]>=5){$covs{$lsplit[1]}{'5fold'}++;}
		if($lsplit[3]>=100){$covs{$lsplit[1]}{'100fold'}++;}
		$covs{$lsplit[1]}{'Total'}++;
		}
close INPUT;
	}
}
#print all covs to file
print OUT "rCRS-base-pos\t5fold\t100fold\tTotal bp\n";
foreach my $p (sort {$a<=>$b} keys %covs){
	print OUT "$p\t$covs{$p}{'5fold'}\t$covs{$p}{'100fold'}\t$covs{$p}{'Total'}\n";
	}
	close OUT;

exit;		
