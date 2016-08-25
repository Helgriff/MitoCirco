#!/usr/bin/perl -w

#Program to put homoplasmic (HF>0.9) mtDNA variants into format for Circos plot data files
use strict;
use warnings;

my($vcf)=@ARGV;

my $outfile = $vcf."_posconvert";
open(OUT, ">$outfile") || die "Cannot open file \"$outfile\" to write to!\n";

open INPUT, $vcf or die "Cannot open $vcf\n";
loop: while (<INPUT>){
	my $Line=$_;
	chomp $Line;
	if($Line=~/\#/){print OUT "$Line\n"; next loop;}
	my @lsplit=split(/\t/,$Line);
	if($lsplit[0]=~/[1-9,X,Y]/){print OUT "$Line\n"; next loop;}
	if($lsplit[0]=~/M/){
		my $pos=$lsplit[1]+8260;
		if($pos>16569){$pos=$lsplit[1]-8309;}
		print OUT "$lsplit[0]\t$pos";
		for(my $c=2;$c<(scalar @lsplit);$c++){print OUT "\t$lsplit[$c]";}
		print OUT "\n";
		}
	}
close INPUT;
close OUT;
exit;		
