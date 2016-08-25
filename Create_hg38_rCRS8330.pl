#!/usr/bin/perl

#Script to Create a hg38 reference with rCRS substituted for rCRS8330 (the rCRS sequence but starting from position 8261 !!!)

my $path1="/users/nhrg/lustre/hg38_rCRS8330"; 
my $file=$path1."/hg38.fa";
my $rCRS8330file="/users/nhrg/lustre/AnalysisScripts/WTCCC10K/Pipeline_MitoCirco/rCRS/rCRSplus8330bp.fasta";
my $outfile=$path1."/hg38_rCRS8330.fa";
open(OUT2, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
my $dp=0;

open INPUT2, $file or die "Cannot open $file\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		if($Line =~/\>chrM/){$dp=1;}
		if($Line =~/\>/ and $Line !~/\>chrM/){$dp=0;}
		if($dp==0){print OUT2 "$Line\n";}
}
close INPUT2;

open INPUT, $rCRS8330file or die "Cannot open $rCRS8330file\n";
	while (<INPUT>){
	my $Line=$_;
	chomp $Line;
	print OUT2 "$Line\n";
}
close INPUT;

close OUT2;

exit;
