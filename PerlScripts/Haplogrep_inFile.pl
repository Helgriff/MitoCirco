#!/usr/bin/perl
use strict;
use warnings;

#Program to convert vcf file (chrM) into Haplogrep input file (rCRS positions)
#Print list of putative heteroplasmic sites

my($path1, $ID, $rCRSseqfile, $pct_homo)=@ARGV;

#define variables
my @DirContent=`ls $path1`;
my %Variants;
my %hetplas_cnt;
my $rCRSseq="";
my $pct_homoRef=100-$pct_homo;

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

##initialise %Variants
for (my $c=0;$c<$countrCRS;$c++){
my $d=$c+1;
$Variants{$d}{'depth'}=0;
$Variants{$d}{'ref'}=$rCRS[$c];
$Variants{$d}{'var'}="NA";
$Variants{$d}{'phet'}=0;
}

##generate %Variants from hg38.vcf file
my $vcf=$path1."/".$ID."_varscan_nodups_hg38.vcf"; 
open INPUT, $vcf or die "Cannot open $vcf\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop;}
		if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
		if($lsplit[4]=~/[\-\+]/){next loop;}
		$lsplit[7]=~s/ADP\=//;
		$lsplit[7]=~s/\;\S+//; #get total depth
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		if($Variants{$lsplit[1]}{'depth'}<$lsplit[7]){$Variants{$lsplit[1]}{'depth'}=$lsplit[7];}
		if($Variants{$lsplit[1]}{'var'}!~/$lsplit[4]/ and $Variants{$lsplit[1]}{'var'}!~/NA/){print "warning: pos $lsplit[1] hash var $Variants{$lsplit[1]}{'var'} does not match file 2nd var $lsplit[4]!!!\n";}
		$Variants{$lsplit[1]}{'var'}=$lsplit[4];
		$Variants{$lsplit[1]}{'phet'}=$lsplit[9];
		if($Variants{$lsplit[1]}{'ref'}!~/$lsplit[3]/){print "warning: pos $lsplit[1] ref $Variants{$lsplit[1]}{'ref'} does not match $lsplit[3]!!!\n";}
}
close INPUT;
my $vcf2=$path1."/".$ID."_varscan_nodups_hg38plus.vcf"; 
open INPUT, $vcf2 or die "Cannot open $vcf2\n";
	loop: while (<INPUT>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop;}
		my @lsplit=split(/\t/,$Line);
		$lsplit[0]=~s/chr//;
		if($lsplit[0]!~/M/){next loop;}
		my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
		if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
		$lsplit[1]=$pp;
		if($lsplit[1]>200 and $lsplit[1]<16400 and $lsplit[0]=~/M/){next loop;}
		if($lsplit[4]=~/[\-\+]/){next loop;}
		$lsplit[7]=~s/ADP\=//;
		$lsplit[7]=~s/\;\S+//; #get total depth
		$lsplit[9]=~s/\%\S+//;
		$lsplit[9]=~s/\S+\://; #get %varfreq
		if($Variants{$lsplit[1]}{'depth'}<$lsplit[7]){$Variants{$lsplit[1]}{'depth'}=$lsplit[7];}
		if($Variants{$lsplit[1]}{'var'}!~/$lsplit[4]/ and $Variants{$lsplit[1]}{'var'}!~/NA/){print "warning: pos $lsplit[1] hash var $Variants{$lsplit[1]}{'var'} does not match file 2nd var $lsplit[4]!!!\n";}
		$Variants{$lsplit[1]}{'var'}=$lsplit[4];
		$Variants{$lsplit[1]}{'phet'}=$lsplit[9];
		if($Variants{$lsplit[1]}{'ref'}!~/$lsplit[3]/){print "warning: pos $lsplit[1] ref $Variants{$lsplit[1]}{'ref'} does not match $lsplit[3]!!!\n";}
}
close INPUT;

##open output file and print list of variants in Haplogrep format
my $outfile2 = $path1."/Main_Haplogrep_In_hg38M_".$ID.".txt";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";		
print OUT2 "SampleID\tRange\tHaplogroup\tPolymorphisms\n";
print OUT2 "$ID\t\"1\-16569\;\"\t\?";

##initialise hash of het category counts
$hetplas_cnt{'R'}=0; #Homo ref (0%)
$hetplas_cnt{'LR'}=0; #Homo ref (>0 & <$pct_homoRef%)
$hetplas_cnt{'LL'}=0; #Het low (>=$pct_homoRef & <25%)
$hetplas_cnt{'LM'}=0; #Het low (>=25 & <50%)
$hetplas_cnt{'HM'}=0; #Het low (>=50 & <75%)
$hetplas_cnt{'HH'}=0; #Het low (>=75 & <$pct_homo%)
$hetplas_cnt{'HV'}=0; #Homo var (>=$pct_homo%)

loop3: foreach my $pos (sort {$a<=>$b} keys %Variants){
		my $gt="0N";
		my $v=$Variants{$pos}{'var'};
		##Assign genotypes and print non-heteroplasmic genos to haplogrep input format
		if($v!~/[\-\+]/ and $Variants{$pos}{'phet'}>$pct_homo){$gt=$pos.$v;}
		if($v!~/[\-\+]/ and $Variants{$pos}{'phet'}<$pct_homoRef 
			#and ($pos==195 or $pos==204 or $pos==207 or $pos==235 or $pos==462 or $pos==489 or $pos==663 or $pos==709 or $pos==769 or $pos==1018 or $pos==1243 
			#or $pos==1736 or $pos==1888 or $pos==2706 or $pos==3010 or $pos==3505 or $pos==4248 or $pos==4580 or $pos==4824 or $pos==4917 or $pos==5460 or $pos==6221 
			#or $pos==6371 or $pos==6392 or $pos==6755 or $pos==7028 or $pos==8251 or $pos==8404 or $pos==8697 or $pos==8701 or $pos==8794 or $pos==8994 or $pos==9140 
			#or $pos==9540 or $pos==10034 or $pos==10310 or $pos==10398 or $pos==10400 or $pos==10463 or $pos==10550 or $pos==10873 or $pos==11251 or $pos==11299 
			#or $pos==11467 or $pos==11947 or $pos==12308 or $pos==12372 or $pos==12705 or $pos==13368 or $pos==13966 or $pos==14470 or $pos==14766 
			#or $pos==14783 or $pos==14798 or $pos==14905 or $pos==15043 or $pos==15301 or $pos==15452 or $pos==15607 or $pos==15884 or $pos==15928 or $pos==16126 
			#or $pos==16129 or $pos==16189 or $pos==16213 or $pos==16223 or $pos==16224 or $pos==16278 or $pos==16290 or $pos==16292 or $pos==16294 or $pos==16311 
			#or $pos==16319)
			and $pos==7028){$gt=$pos.$Variants{$pos}{'ref'};}
		
		if($gt!~/N/){print OUT2 "\t$gt";} #Don't add '0N' genotypes/heteroplasmic
		##Count heteroplasmy catergories
		if($Variants{$pos}{'phet'}==0){$hetplas_cnt{'R'}++;} #Homo ref (0%)
		if($Variants{$pos}{'phet'}>0 and $Variants{$pos}{'phet'}<$pct_homoRef){$hetplas_cnt{'LR'}++;} #Homo ref (<$pct_homoRef%)
		if($Variants{$pos}{'phet'}>=$pct_homoRef and $Variants{$pos}{'phet'}<25){$hetplas_cnt{'LL'}++;} #Het low (>=$pct_homoRef & <25%)
		if($Variants{$pos}{'phet'}>=25 and $Variants{$pos}{'phet'}<50){$hetplas_cnt{'LM'}++;} #Het low (>=25 & <50%)
		if($Variants{$pos}{'phet'}>=50 and $Variants{$pos}{'phet'}<75){$hetplas_cnt{'HM'}++;} #Het low (>=50 & <75%)
		if($Variants{$pos}{'phet'}>=75 and $Variants{$pos}{'phet'}<$pct_homo){$hetplas_cnt{'HH'}++;} #Het low (>=75 & <$pct_homo%)
		if($Variants{$pos}{'phet'}>=$pct_homo){$hetplas_cnt{'HV'}++;} #Homo var (>=$pct_homo%)
	}
	print OUT2 "\n";
close OUT2;

##get total counts of each heteroplasmy category per patient
my $outfile4 = $path1."/Heteroplasmy_pcnt_CategoryCounts_hg38M_".$ID.".txt";
open(OUT4, ">$outfile4") || die "Cannot open file \"$outfile4\" to write to!\n";
print OUT4 "ID\tR (0\%)\tLR (\<$pct_homoRef\%)\tLL (\<25\%)\tLM (\<50\%)\tHM (\>50\%)\tHH (\>75\%)\tHV (\>$pct_homo\%)\n";
print OUT4 "$ID\t$hetplas_cnt{'R'}\t$hetplas_cnt{'LR'}\t$hetplas_cnt{'LL'}\t$hetplas_cnt{'LM'}\t$hetplas_cnt{'HM'}\t$hetplas_cnt{'HH'}\t$hetplas_cnt{'HV'}\n";
close OUT4;

exit;
