#!/usr/bin/perl
use strict;
use warnings;

#Program to convert MULTISAMPLE vcf file (chrM) into Haplogrep input file (rCRS positions)
#Print list of putative heteroplasmic sites

my($path1, $vfile, $rCRSseqfile)=@ARGV;

#define variables
my @DirContent=`ls $path1`;
my %Variants;
my $rCRSseq="";
#my $pct_homoRef=100-$pct_homo;

open INPUT2, $rCRSseqfile or die "Cannot open $rCRSseqfile\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\>/){next loop2;}
		$rCRSseq=$rCRSseq.$Line;
}
close INPUT2;
my @rCRS=split(//,$rCRSseq);
my $countrCRS=scalar(@rCRS);
my %ids=();
my $sno=0;

##generate %Variants from hg38.vcf file
my $vcf=$path1."/".$vfile; 
open INPUT, $vcf or die "Cannot open $vcf\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\##/){next loop;}
		if($Line=~/\#CHROM/){
			my @headsplit = split(/\t/,$Line);
			##initialise %Variants for each rCRS base for each sample
			for (my $s=9;$s<scalar(@headsplit);$s++){
			$sno++;
			$ids{$s}=$headsplit[$s];
				for (my $c=0;$c<$countrCRS;$c++){
					my $d=$c+1;
					#$Variants{$s}{$d}{'depth'}=0;
					$Variants{$s}{$d}{'ref'}=$rCRS[$c];
					$Variants{$s}{$d}{'var'}="NA";
					#$Variants{$s}{$d}{'phet'}=0;
					}
				}
				next loop;
			}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop;} ##chrM only!!!
		if($lsplit[4]=~/[\-\+]/ or $lsplit[4]=~/\S\S/ or $lsplit[3]=~/\S\S/){next loop;} ##no indels
		#$lsplit[7]=~s/ADP\=//;
		#$lsplit[7]=~s/\;\S+//; #get total depth
		for(my $s=9;$s<scalar(@lsplit);$s++){
			#$lsplit[$s]=~s/\%\S+//;
			#$lsplit[$s]=~s/\S+\://; #get %varfreq
			if($lsplit[$s]=~/1\/1/){
			#if($Variants{$s}{$lsplit[1]}{'depth'}<$lsplit[7]){$Variants{$s}{$lsplit[1]}{'depth'}=$lsplit[7];}
			if($Variants{$s}{$lsplit[1]}{'var'}!~/$lsplit[4]/ and $Variants{$s}{$lsplit[1]}{'var'}!~/NA/){print "warning: pos $lsplit[1] hash var $Variants{$s}{$lsplit[1]}{'var'} does not match file 2nd var $lsplit[4] for sample no $s!!!\n";}
			$Variants{$s}{$lsplit[1]}{'var'}=$lsplit[4];
			#$Variants{$s}{$lsplit[1]}{'phet'}=$lsplit[9];
			if($Variants{$s}{$lsplit[1]}{'ref'}!~/$lsplit[3]/){print "warning: pos $lsplit[1] ref $Variants{$s}{$lsplit[1]}{'ref'} does not match $lsplit[3] for sample no $s!!!\n";}
			}#if homoplasmic non-rCRS genotype 
		}#per sample
}
close INPUT;

##open output file and print list of variants in Haplogrep format
my $outfile2 = $path1."/Haplogrep_In_hg38M_".$vfile.".txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";		
print OUT2 "SampleID\tRange\tHaplogroup\tPolymorphisms\n";
for(my $c=0;$c<$sno;$c++){
my $s=$c+9;	
print OUT2 "$ids{$s}\t\"1\-16569\;\"\t\?";

loop3: foreach my $pos (sort {$a<=>$b} keys %{$Variants{$s}}){
		my $gt="0N";
		my $v=$Variants{$s}{$pos}{'var'};
		##Assign genotypes and print non-heteroplasmic genos to haplogrep input format
		$gt=$pos.$v;
		if($gt!~/N/){print OUT2 "\t$gt";} #Don't add '0N' genotypes/heteroplasmic or 'NA' vars
	}
	print OUT2 "\n";
}#for sample id
close OUT2;

exit;
