#!/usr/bin/perl

#####################################################################
# Read target regions into hash
# Go through each line of pileup file and identify whether it lies within target region
# if yes then increment corresponding target counts in hash
# Calculate a range of coverage data
######################################################################

use strict;
use warnings;
use Getopt::Long;

my $path1="rootfilepath";
my $path2="outfilepath";
my $file="infilenameANDpath";
my $batchID="overall_sample_ID";
my $TargetFile="bed_style_file_of_chr_pos1_pos2_name.txt";

my $Results=GetOptions("inPath1=s"=>\$path1, "inPath2=s"=>\$path2, "inFile=s"=>\$file, "targets=s"=>\$TargetFile, "batchID=s"=>\$batchID);

my %files;
my @Patient_ID;
if($file =~ /(\S+\/)(\S+)\.pileup$/){$files{$2}=$file; push(@Patient_ID,$2);}

#open target regions file
open (FILE, $TargetFile) || die "File not found\n";
print "$TargetFile\n";
#Create hash of target regions and hash of no. of entries per chr
my %Targetregions;
my %Targets_per_chr;
my $targetbase_count=0;
my $targetbase_countN=0;
while (<FILE>) {
	chomp($_);
	my @targetlinesplit = split(/\t/, $_);
	my $chr=$targetlinesplit[0];
	my $T_start=$targetlinesplit[1];
	my $T_end=$targetlinesplit[2];
	my $T_info=$targetlinesplit[3];
	my $Tlength =($T_end+1)-$T_start;
	$targetbase_countN+=$Tlength;
	if($chr=~/chrM/){$targetbase_count+=$Tlength;}
	if(!exists $Targets_per_chr{$chr}){$Targets_per_chr{$chr}=0;}
	$Targetregions{$chr}[$Targets_per_chr{$chr}][0]=$T_start;
	$Targetregions{$chr}[$Targets_per_chr{$chr}][1]=$T_end;
	$Targetregions{$chr}[$Targets_per_chr{$chr}][2]=0; #num. bases covered 1+
	$Targetregions{$chr}[$Targets_per_chr{$chr}][3]=0; #total coverage per region (1+)
	$Targetregions{$chr}[$Targets_per_chr{$chr}][4]=$T_info; #target region name
	$Targetregions{$chr}[$Targets_per_chr{$chr}][5]=0; #num. bases covered 100+
	$Targets_per_chr{$chr}++;
}
close FILE; 

my $Targetregions_ref = \%Targetregions;
my $Targets_per_chr_ref = \%Targets_per_chr;

#open output file for mean and No./% bases covered
my $outfile2 = $path1."/Coverage_from_pileup-mean_bases_chrM_".$batchID.".txt";
open(OUT2, ">>$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";
print OUT2 "Sample.ID\tNo.Target.Bases\tMean.Read.Depth\tMin.Depth\tMax.Depth\tNo.Bases.100-fold\tPcnt.Bases.100-fold\tNo.Bases.1-fold\tPcnt.Bases.1-fold\n";

#open output file for mean and No./% bases covered
my $outfile3 = $path1."/Coverage_from_pileup-mean_bases_chrAll_".$batchID.".txt";
open(OUT3, ">>$outfile3") || die "Cannot open file \"$outfile3\" to write to!\n";
print OUT3 "Sample.ID\tNo.Target.Bases\tMean.Read.Depth\tMin.Depth\tMax.Depth\tNo.Bases.100-fold\tPcnt.Bases.100-fold\tNo.Bases.1-fold\tPcnt.Bases.1-fold\n";

#read all pileup files
my $num_patients = scalar @Patient_ID;
my ($Results_mean_bases_cov,$Results_mean_bases_covN);
for(my $p1=0; $p1<$num_patients; $p1++){
	 ($Results_mean_bases_cov,$Results_mean_bases_covN) = Read_pileup($path2, $p1, $Patient_ID[$p1],$files{$Patient_ID[$p1]},$Targetregions_ref,$Targets_per_chr_ref, $targetbase_count, $targetbase_countN);
	 print OUT2 "$Results_mean_bases_cov\n";
	 print OUT3 "$Results_mean_bases_covN\n"; 
	 }
close OUT2;
close OUT3;

##SUBROUTINES###########################################################################
sub Read_pileup{
	my ($path, $p1, $ID, $pileup_file, $ref_Tregions, $ref_TperChr, $Tbase_count, $Tbase_countN)=@_;
	my %T_regions = %$ref_Tregions;
	my %T_perChr = %$ref_TperChr;
	my %Startfrom;
	my $Bcount_100fold=0;
	my $Bcount_1fold=0;
	my $totalcov=0;
	my $max=0;
	my $min=10000000;
	my $Bcount_100foldN=0;
	my $Bcount_1foldN=0;
	my $totalcovN=0;
	my $maxN=0;
	my $minN=10000000;
	
	open PILEUP, $pileup_file or die "Pileup file not found\n";
	ploop: while (<PILEUP>){
		my $line = $_;
		chomp $line;
		my @linesplit = split (/\t/,$line);
		my $chr = $linesplit[0];
		if(!exists $T_regions{$chr}){next;}
		my $pos = $linesplit[1];
		my $cov = $linesplit[3];
 
		if(($pos<=200 or $pos>=16400) and $chr=~/chrM/ and $pileup_file=~/hg38.pileup/){next ploop;} #use values from hg38plus for region covering origin of rCRS
 
	#loop through chr specific targets
	if(!exists $Startfrom{$chr}){$Startfrom{$chr}=0;}
	for (my $count = $Startfrom{$chr}; $count<$T_perChr{$chr}; $count++){	
		
		#if pos is less than tstart, make startfrom{chr} equal to count and move onto next line of file
		if($pos < $T_regions{$chr}[$count][0]){$Startfrom{$chr} = $count; last;}
		
		#if pos is greater than or equal to tstart and pos is less than or equal to tend, add cov to hash and make startfrom{chr} equal to count and move onto next file line
		if(($pos >= $T_regions{$chr}[$count][0]) && ($pos <= $T_regions{$chr}[$count][1])){
			if($cov>=100){$T_regions{$chr}[$count][5]++;
							$Bcount_100foldN++;	
							if($chr=~/chrM/){$Bcount_100fold++;} 
						 } #count 100fold covered bases on target - total and per target
			if($chr=~/chrM/){$Bcount_1fold++;} #count bases on target
							 $Bcount_1foldN++;
			$T_regions{$chr}[$count][2]++; #1-fold count
			$T_regions{$chr}[$count][3]+=$cov; #total coverage per region (1-fold)
			if($chr=~/chrM/){$totalcov+=$cov;} #add up total coverage
			if($chr=~/chrM/ and $cov>$max){$max=$cov;}#set max
			if($chr=~/chrM/ and $cov<$min){$min=$cov;}#set min
			$totalcovN+=$cov; #add up total coverage
			if($cov>$maxN){$maxN=$cov;}#set max
			if($cov<$minN){$minN=$cov;}#set min
			$Startfrom{$chr} = $count; last;
			}
	}#end of for target regions loop
}#end of while pileup file loop
close PILEUP;

####
## Add another file loop for hg38plus pileup to get coverage for bases 1-100 and 16470-16569
my $pileupplus_file="NA";
if($pileup_file=~/(\S+hg38).pileup/){
	my $pre=$1;
	$pileupplus_file=$pre."plus.pileup";
	open PILEUP, $pileupplus_file or die "PileupPlus $pileupplus_file not found\n";
	pploop: while (<PILEUP>){
		my $line = $_;
		chomp $line;
		my @linesplit = split (/\t/,$line);
		my $chr = $linesplit[0];
		if($chr !~/chrM/){next pploop;}
		my $pos = $linesplit[1];
		my $cov = $linesplit[3];
 
 		##Convert position into correct rCRS positions
		my $ppos = $pos+8260;
		if($ppos>16569){$ppos = $pos-8309;}
		if($ppos>200 and $ppos<16400){next pploop;}
		$pos=$ppos;
	#loop through chr specific targets
	$Startfrom{$chr}=0;
	for (my $count = $Startfrom{$chr}; $count<$T_perChr{$chr}; $count++){	
		
		#if pos is less than tstart, make startfrom{chr} equal to count and move onto next line of file
		if($pos < $T_regions{$chr}[$count][0]){$Startfrom{$chr} = $count; last;}
		
		#if pos is greater than or equal to tstart and pos is less than or equal to tend, add cov to hash and make startfrom{chr} equal to count and move onto next file line
		if(($pos >= $T_regions{$chr}[$count][0]) && ($pos <= $T_regions{$chr}[$count][1])){
			if($cov>=100){$T_regions{$chr}[$count][5]++;
							$Bcount_100foldN++;	
							if($chr=~/chrM/){$Bcount_100fold++;} 
						 } #count 100fold covered bases on target - total and per target
			if($chr=~/chrM/){$Bcount_1fold++;} #count bases on target
							 $Bcount_1foldN++;
			$T_regions{$chr}[$count][2]++; #1-fold count
			$T_regions{$chr}[$count][3]+=$cov; #total coverage per region (1-fold)
			if($chr=~/chrM/){$totalcov+=$cov;} #add up total coverage
			if($chr=~/chrM/ and $cov>$max){$max=$cov;}#set max
			if($chr=~/chrM/ and $cov<$min){$min=$cov;}#set min
			$totalcovN+=$cov; #add up total coverage
			if($cov>$maxN){$maxN=$cov;}#set max
			if($cov<$minN){$minN=$cov;}#set min
			$Startfrom{$chr} = $count; last;
			}
	}#end of for target regions loop
}#end of while pileup file loop
close PILEUP;
}
####end pileup plus loop #########################

my $mean_cov_TT = $totalcov/$Tbase_count;
my $mean_cov_TTN = $totalcovN/$Tbase_countN;
my $pct_Bases1fold = ($Bcount_1fold/$Tbase_count)*100;
my $pct_Bases100fold = ($Bcount_100fold/$Tbase_count)*100;
my $pct_Bases1foldN = ($Bcount_1foldN/$Tbase_countN)*100;
my $pct_Bases100foldN = ($Bcount_100foldN/$Tbase_countN)*100;

#open per target output file
my $outfile = $path."/Coverage_perTarget_".$ID."_alltargets.txt";
open(OUT, ">>$outfile") || die "Cannot open file \"$outfile\" to write to!\n";
print OUT "Patient\tChromosome\tTarget Name\tTarget Start Position\tTarget End Position\tTarget Length\tTotal Coverage for all Target Bases\tMean per Base Coverage\tNo. Target Bases Covered (100-fold)\t% Target Bases Covered (100-fold)\tNo. Target Bases Covered (1-fold)\t% Target Bases Covered (1-fold)\n";

my $num_targets_total=0;

foreach my $ch (sort keys %T_regions){
	for (my $ct=0; $ct < $T_perChr{$ch}; $ct++){
		$num_targets_total++;
		my $Tgt_lnth = ($T_regions{$ch}[$ct][1]+1)-$T_regions{$ch}[$ct][0];
		my $mean_per_base_cov=$T_regions{$ch}[$ct][3]/$Tgt_lnth;
		my $pct_bases_1_fold =($T_regions{$ch}[$ct][2]/$Tgt_lnth)*100;
		my $pct_bases_100_fold =($T_regions{$ch}[$ct][5]/$Tgt_lnth)*100;
		#print per target info to file - all targets
		print OUT "$ID\t$ch\t$T_regions{$ch}[$ct][4]\t$T_regions{$ch}[$ct][0]\t$T_regions{$ch}[$ct][1]\t$Tgt_lnth\t$T_regions{$ch}[$ct][3]\t$mean_per_base_cov\t$T_regions{$ch}[$ct][5]\t$pct_bases_100_fold\t$T_regions{$ch}[$ct][2]\t$pct_bases_1_fold\n";
				
	#re-initialise hash coverage values to 0
	$Targetregions{$ch}[$ct][2]=0;
	$Targetregions{$ch}[$ct][3]=0;
	$Targetregions{$ch}[$ct][5]=0;
		}}
close OUT;		

#return coverages
my $results_mean_bases_cov = join('	', $ID, $Tbase_count, $mean_cov_TT, $min, $max, $Bcount_100fold, $pct_Bases100fold, $Bcount_1fold, $pct_Bases1fold);
my $results_mean_bases_covN = join('	', $ID, $Tbase_countN, $mean_cov_TTN, $minN, $maxN, $Bcount_100foldN, $pct_Bases100foldN, $Bcount_1foldN, $pct_Bases1foldN);
return ($results_mean_bases_cov, $results_mean_bases_covN);
}#end of sub

exit;
