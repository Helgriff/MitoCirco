#!/usr/bin/perl -w
use strict;
use warnings;

#Program to summarise (Blue) Numts predicted from split chrM and chr(Nuclear) alignments

my $path1="/home/nhrg/WORKING_DATA/SourceBio/NumtS";
my $batchID="2876x";
my %NumtTot;
my %NumtTotnc;
my %NumtTotmt;

my @DirContent=`ls $path1`;
loopF: foreach my $file (@DirContent){
	chomp $file;
if($file=~/Linkncmt_(\S+).txt/){
my $id=$1;
open INPUT, $file or die "Cannot open $file\n";
	loop: while (<INPUT>){
		my $Line=$_;
		if($Line!~/hsM/){next loop;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/hs//;
		$lsplit[3]=~s/hs//;
		if($lsplit[0]=~/M/){if(!exists $NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}=0;}
							if(!exists $NumtTotnc{$lsplit[3]}{$lsplit[4]}){$NumtTotnc{$lsplit[3]}{$lsplit[4]}=0;}
							if(!exists $NumtTotmt{$lsplit[1]}){$NumtTotmt{$lsplit[1]}=0;}
							$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}++;
							$NumtTotnc{$lsplit[3]}{$lsplit[4]}++;
							$NumtTotmt{$lsplit[1]}++;
							}
		if($lsplit[3]=~/M/){if(!exists $NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}){$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}=0;}
							if(!exists $NumtTotnc{$lsplit[0]}{$lsplit[1]}){$NumtTotnc{$lsplit[0]}{$lsplit[1]}=0;}
							if(!exists $NumtTotmt{$lsplit[4]}){$NumtTotmt{$lsplit[4]}=0;}
							$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}++;
							$NumtTotnc{$lsplit[0]}{$lsplit[1]}++;
							$NumtTotmt{$lsplit[4]}++;
							}
	}#while
close INPUT;
}#if matches
}#each file

##Print to outfiles
my $outfile2 = $path1."/Numts_Blue_Summary_".$batchID.".txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";

print OUT2 "rCRS_position\thg38_Chrom\thg38_position\tNumber_of_Samples\n";
foreach my $pm (sort {$a<=>$b} keys %NumtTot){
	foreach my $ch (sort keys %{$NumtTot{$pm}}){
		foreach my $pch (sort {$a<=>$b} keys %{$NumtTot{$pm}{$ch}}){
		 print OUT2 "$pm\t$ch\t$pch\t$NumtTot{$pm}{$ch}{$pch}\n";
		}
	}
}
close OUT2;

my $outfile3 = $path1."/Numts_Blue_Summary_NuclearOnly".$batchID.".txt";
open(OUT3, ">$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
print OUT3 "hg38_Chrom\thg38_position\tNumber_of_Samples\n";
foreach my $ch (sort keys %NumtTotnc){
	foreach my $pch (sort {$a<=>$b} keys %{$NumtTotnc{$ch}}){
	 print OUT3 "$ch\t$pch\t$NumtTotnc{$ch}{$pch}\n";
	}
}
close OUT3;

my $outfile4 = $path1."/Numts_Blue_Summary_mtOnly".$batchID.".txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";
print OUT4 "rCRS_position\tNumber_of_Samples\n";
foreach my $pch (sort {$a<=>$b} keys %NumtTotmt){
	print OUT4 "$pch\t$NumtTotmt{$pch}\n";
	}
close OUT4;

exit;
