#!/usr/bin/perl -w

#Program to summarise Numts predicted from *mtDNA.sam alignment files
use strict;
use warnings;

my($path1,$prefix,$batchID)=@ARGV;

my %NumtTot;
my %NumtPerS;

my @DirContent=`ls $path1`;
loopF: foreach my $folder (@DirContent){
	chomp $folder;
if($folder=~/($prefix\S+)/){
my $id=$1;
my $file=$path1."/".$folder."/circos/Linkncmt_".$id.".txt";
if(-e $file){
open INPUT, $file or die "Cannot open $file\n";
	loop: while (<INPUT>){
		my $Line=$_;
		if($Line!~/hsM/){next loop;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/hs//;
		$lsplit[3]=~s/hs//;
		if($lsplit[0]=~/M/){if(!exists $NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}=0;}
							if(!exists $NumtPerS{$id}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){
								$NumtPerS{$id}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}=0;
								$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}++;
								}
							}
		if($lsplit[3]=~/M/){if(!exists $NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}){$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}=0;}
							if(!exists $NumtPerS{$id}{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}){
								$NumtPerS{$id}{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}=0;
								$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}++;
								}
							}		
	}
close INPUT;
}
my $file2=$path1."/".$folder."/circos/Linknc_".$id.".txt";
if(-e $file2){
open INPUT2, $file2 or die "Cannot open $file2\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
	##process 2nd file
	if($Line!~/hsM/){next loop2;}
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/hs//;
		$lsplit[3]=~s/hs//;
		if($lsplit[0]=~/M/){if(!exists $NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}=0;}
							if(!exists $NumtPerS{$id}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){
								$NumtPerS{$id}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}=0;
								$NumtTot{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}++;
								}
							}
		if($lsplit[3]=~/M/){if(!exists $NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}){$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}=0;}
							if(!exists $NumtPerS{$id}{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}){
								$NumtPerS{$id}{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}=0;
								$NumtTot{$lsplit[4]}{$lsplit[0]}{$lsplit[1]}++;
								}
							}
	}
close INPUT2;
}
}#if matches prefix
}#each folder

##Print to outfiles
my $outfile = $path1."/Results_".$batchID."/Numts_perSample_$batchID.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $outfile2 = $path1."/Results_".$batchID."/Numts_Summary_$batchID.txt";
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

print OUT "ID\trCRS_position\thg38_Chrom\thg38_position\n";
foreach my $i (sort keys %NumtPerS){
	foreach my $pm (sort {$a<=>$b} keys %{$NumtPerS{$i}}){
		foreach my $ch (sort keys %{$NumtPerS{$i}{$pm}}){
			foreach my $pch (sort {$a<=>$b} keys %{$NumtPerS{$i}{$pm}{$ch}}){
			print OUT "$i\t$pm\t$ch\t$pch\n";
			}
		}
	}
}
close OUT;
exit;		
