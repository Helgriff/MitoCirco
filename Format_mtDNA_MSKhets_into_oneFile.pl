#!/usr/bin/perl -w

#Program to put mtDNA heteroplasmies called by Mitoseek(++) into format for Circos plot data files
use strict;
use warnings;

my($path1,$path2,$ID2)=@ARGV;

my $outfile = $path2."/MSKhets_Sig1p.txt";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";

my @DirContent=`ls $path1`;
foreach my $folder (@DirContent){
	chomp $folder;
if($folder=~/${ID2}_nodups_hg38_mitoSK_heteroplasmy.txt/){
	open INPUT, $path1."/".$folder or die "Cannot open $folder\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		my $adjP=sprintf("%.3f",$lsplit[27]);
		my $het=sprintf("%.3f",$lsplit[11]);
		#if multiple testing corrected Fisher pvalue < 0.05 and heteroplasmy >1%
		if($adjP<0.05 and $het>0.01){print OUT "hsM\t$lsplit[1]\t$lsplit[1]\t$het\tcolor\=vdgreen\n";} 
		}
close INPUT;
}
}
close OUT;

exit;		
