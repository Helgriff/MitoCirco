#!/usr/bin/perl -w
use strict;
use warnings;

#Program to get heteroplasmic variants into per sample MitoMaster input format and also print local hetero- and homo-plasmic files

my($path1,$ID2,$PCNT_HOMO,$file)=@ARGV;

my $outfile = $path1."/MitoMasterOut_lessthan_".$PCNT_HOMO."pcnt_Heteroplasmic_".$ID2.".txt.local";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";

my $outfile2 = $path1."/MitoMasterOut_morethan_".$PCNT_HOMO."pcnt_Homoplasmic_".$ID2.".txt.local";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";

my $outfile3 = $path1."/MitoMaster_In_".$ID2."_Heteroplasmies.txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";

##Read in local MitoMaster data file
my %MMdata;
open INPUT, $file or die "Cannot open MitoMaster local data file: $file\n";
my $head=<INPUT>;
print OUT "ID\t$head";
loop: while (<INPUT>){
	my $Line2=$_;
	chomp $Line2;
	my @lsplit2=split(/\t/,$Line2);
	$MMdata{$lsplit2[0]}{$lsplit2[2]}{$lsplit2[3]}=$Line2;
}
close INPUT;

##Get %heteroplasmies
my %hets;
my $file3 = $path1."/".$ID2."_varscan_nodups_hg38.vcf";	
open INPUT2, $file3 or die "Cannot open $file3\n";
loop2: while (<INPUT2>){
	my $Line=$_;
	if($Line=~/\#/){next loop2;}
	chomp $Line;
	my @lsplit=split(/\t/,$Line);
	$lsplit[0]=~s/chr//;
	if($lsplit[0]!~/M/){next loop2;} #chrM only
	if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop2;}
	$lsplit[7]=~s/ADP\=//;
	$lsplit[7]=~s/\;\S+//; #get total depth
	$lsplit[9]=~s/\%\S+//;
	$lsplit[9]=~s/\S+\://; #get %varfreq
	$hets{$ID2}{$lsplit[1]}=$lsplit[9];
	my $ID3 = $ID2."_".$lsplit[9]."\%";
	my $var = $lsplit[3].$lsplit[1].$lsplit[4];
	#Only print single base ref/alts (SNVs)
	unless($lsplit[3]=~/\S\S/ or $lsplit[4]=~/\S\S/ or $lsplit[3]=~/N/){
		#Homoplasmic
		if($lsplit[9]>=$PCNT_HOMO){
			if(exists $MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){print OUT2 "$ID3\t$MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}\n";}
			}
		#Heteroplasmic	
		if($lsplit[9]<$PCNT_HOMO and $lsplit[9]>(100-$PCNT_HOMO)){
			if(exists $MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){print OUT "$ID3\t$MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}\n"; next loop2;
				}else{print OUT3 "$ID3\t$var\n";}
			}
		}
}
close INPUT2;
my $file4 = $path1."/".$ID2."_varscan_nodups_hg38plus.vcf";	
open INPUT2, $file4 or die "Cannot open $file4\n";
loop3: while (<INPUT2>){
	my $Line=$_;
	if($Line=~/\#/){next loop3;}
	chomp $Line;
	my @lsplit=split(/\t/,$Line);
	$lsplit[0]=~s/chr//;
	if($lsplit[0]!~/M/){next loop3;} #chrM only
	my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
	if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
	$lsplit[1]=$pp;
	if($lsplit[1]>200 and $lsplit[1]<16400){next loop3;}
	$lsplit[7]=~s/ADP\=//;
	$lsplit[7]=~s/\;\S+//; #get total depth
	$lsplit[9]=~s/\%\S+//;
	$lsplit[9]=~s/\S+\://; #get %varfreq
	$hets{$ID2}{$lsplit[1]}=$lsplit[9];
	my $ID3 = $ID2."_".$lsplit[9]."\%";
	my $var = $lsplit[3].$lsplit[1].$lsplit[4];
	#Only print single base ref/alts (SNVs)
	unless($lsplit[3]=~/\S\S/ or $lsplit[4]=~/\S\S/ or $lsplit[3]=~/N/){
		#Homoplasmic
		if($lsplit[9]>=$PCNT_HOMO){
			if(exists $MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){print OUT2 "$ID3\t$MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}\n";}
			}
		#Heteroplasmic	
		if($lsplit[9]<$PCNT_HOMO and $lsplit[9]>(100-$PCNT_HOMO)){
			if(exists $MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){print OUT "$ID3\t$MMdata{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}\n"; next loop3;
				}else{print OUT3 "$ID3\t$var\n";}
			}
		}
}
close INPUT2;
close OUT3;
close OUT2;
close OUT;

exit;		
