#!/usr/bin/perl -w

#Program to put all *mtDNA.pileup files into same file and to get %heteroplasmy counts into one files

use strict;
use warnings;

my($path1,$prefix,$Q,$PCNT_HOMO,$BatchID)=@ARGV;

my $outfile = $path1."/Results_".$BatchID."/All_pileups_transposed_chrM_".$BatchID.".txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path1."/Results_".$BatchID."/All_hets_transposed_chrM_".$BatchID.".txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";

my @DirContent=`ls $path1`;
my %covs;

my @DirContent2=`ls $path1`;
my %hets;

###Get coverage depths
floop:foreach my $file (@DirContent){
	chomp $file;
if($file=~/($prefix\S+)/){
	my $ID=$1;
	#initialise %covs per file
	for(my $c=1;$c<=16569;$c++){$covs{$ID}{$c}=0;}
	my $file2 = $path1."/".$file."/coverage/".$ID."_nodups_".$Q."_hg38.pileup";	
	if(-e $file2){
	open INPUT, $file2 or die "Cannot open $file2\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop;} #chrM only
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		$covs{$ID}{$lsplit[1]}=$lsplit[3];
		}
	close INPUT;
	}
	my $file5 = $path1."/".$file."/coverage/".$ID."_nodups_".$Q."_hg38plus.pileup";	
	if(-e $file5){
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
		$covs{$ID}{$lsplit[1]}=$lsplit[3];
		}
close INPUT;
	}
}
}
#print all covs to file
print OUT "rCRS-base-pos";
foreach my $p (sort keys %covs){print OUT "\t$p";}
print OUT "\n";
for(my $c=1;$c<=16569;$c++){
	print OUT "$c";
	foreach my $p (sort keys %covs){
		print OUT "\t$covs{$p}{$c}";
	}
	print OUT "\n";
}
close OUT;

###Get %heteroplasmies
floop2:foreach my $file (@DirContent2){
	chomp $file;
if($file=~/($prefix\S+)/){
	my $ID2=$1;
	#initialise %hets per file
	for(my $c=1;$c<=16569;$c++){$hets{$ID2}{$c}=0;}
	my $file3 = $path1."/".$file."/varscan2/".$ID2."_varscan_nodups_hg38.vcf";	
	if(-e $file3){
	open INPUT2, $file3 or die "Cannot open $file3\n";
	##my $outfile3 = $path1."/".$file."/varscan2/MitoMaster_In_".$ID2."_Heteroplasmies.txt";
	##open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		if($Line=~/\#/){next loop2;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop2;} #chrM only
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop2;}
		#if($lsplit[1]>16569){$lsplit[1]=$lsplit[1]-16569;} #convert positions of rCRSplus 700bp back to rCRS 1-16569
		$lsplit[7]=~s/ADP\=//;
		$lsplit[7]=~s/\;\S+//; #get total depth
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		$hets{$ID2}{$lsplit[1]}=$lsplit[9];
		##my $ID3 = $ID2."_".$lsplit[9]."\%";
		##my $var = $lsplit[3].$lsplit[1].$lsplit[4];
		##unless($lsplit[3]=~/\S\S/ or $lsplit[4]=~/\S\S/ or $lsplit[3]=~/N/){if($lsplit[9]<$PCNT_HOMO and $lsplit[9]>(100-$lsplit[9])){print OUT3 "$ID3\t$var\n";}}
		}
	close INPUT2;
	##close OUT3;
	} #if vcf file exists

	my $file8 = $path1."/".$file."/varscan2/".$ID2."_varscan_nodups_hg38plus.vcf";	
	if(-e $file8){
	open INPUT2, $file8 or die "Cannot open $file8\n";
	loop4: while (<INPUT2>){
		my $Line=$_;
		if($Line=~/\#/){next loop4;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop4;} #chrM only
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]>200 and $lsplit[1]<16400){next loop4;}
		#if($lsplit[1]>16569){$lsplit[1]=$lsplit[1]-16569;} #convert positions of rCRSplus 700bp back to rCRS 1-16569
		$lsplit[7]=~s/ADP\=//;
		$lsplit[7]=~s/\;\S+//; #get total depth
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		$hets{$ID2}{$lsplit[1]}=$lsplit[9];
		##my $ID3 = $ID2."_".$lsplit[9]."\%";
		##my $var = $lsplit[3].$lsplit[1].$lsplit[4];
		##unless($lsplit[3]=~/\S\S/ or $lsplit[4]=~/\S\S/ or $lsplit[3]=~/N/){if($lsplit[9]<$PCNT_HOMO and $lsplit[9]>(100-$lsplit[9])){print OUT3 "$ID3\t$var\n";}}
		}
	close INPUT2;
	##close OUT3;
	} #if vcf file exists	
	
	} #file in dir matches prefix
} #foreach file in dir

#print all heteroplasmy %s to file2
print OUT2 "rCRS-base-pos";
foreach my $p (sort keys %hets){print OUT2 "\t$p";}
print OUT2 "\n";
for(my $c=1;$c<=16569;$c++){
	print OUT2 "$c";
	foreach my $p (sort keys %hets){
		print OUT2 "\t$hets{$p}{$c}";
	}
	print OUT2 "\n";
}
close OUT2;

exit;		
