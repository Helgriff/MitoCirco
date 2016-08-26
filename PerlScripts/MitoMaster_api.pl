#!/usr/bin/perl

my($path1, $ID, $rCRSseqfile, $PCNT_HOMO)=@ARGV;

#define variables
my @DirContent=`ls $path1`;
my %Variants;
my %hetplas_cnt;
my $rCRSseq="";

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
$Variants{$d}{'ref'}=$rCRS[$c];
$Variants{$d}{'var'}="NA";
}

##generate %Variants from *.vcf file
my $vcf=$path1."/".$ID."_varscan_nodups_hg38.vcf"; 
open INPUT, $vcf or die "Cannot open $vcf\n";
loop: while (<INPUT>){
	my $Line=$_;
	chomp $Line;
	if($Line=~/\#/){next loop;}
	my @lsplit=split(/\t/,$Line);
	$lsplit[0]=~s/chr//;
	if($lsplit[0]!~/M/){next loop;}
	if($lsplit[6]!~/PASS/){next loop;}
	if($lsplit[4]=~/[\-\+]/){next loop;}
	if($lsplit[1]<=200 or $lsplit[1]>=16400 and $lsplit[0]=~/M/){next loop;}
	$lsplit[7]=~s/ADP\=//;
	$lsplit[7]=~s/\;\S+//; #get total depth
	#if($lsplit[7]<50){next loop;}
	$lsplit[9]=~s/\%\S+//;
	$lsplit[9]=~s/\S+\://; #get %varfreq
	if($lsplit[9]<$PCNT_HOMO){next loop;}	
	if($Variants{$lsplit[1]}{'var'}!~/$lsplit[4]/ and $Variants{$lsplit[1]}{'var'}!~/NA/){print "warning: pos $lsplit[1] hash var $Variants{$lsplit[1]}{'var'} does not match file 2nd var $lsplit[4]!!!\n";}
	$Variants{$lsplit[1]}{'var'}=$lsplit[4];
	if($Variants{$lsplit[1]}{'ref'}!~/$lsplit[3]/){print "warning: pos $lsplit[1] ref $Variants{$lsplit[1]}{'ref'} does not match $lsplit[3]!!!\n";}
}
close INPUT;
my $vcf=$path1."/".$ID."_varscan_nodups_hg38plus.vcf"; 
open INPUT, $vcf or die "Cannot open $vcf\n";
loop: while (<INPUT>){
	my $Line=$_;
	chomp $Line;
	if($Line=~/\#/){next loop;}
	my @lsplit=split(/\t/,$Line);
	$lsplit[0]=~s/chr//;
	if($lsplit[0]!~/M/){next loop;}
	if($lsplit[6]!~/PASS/){next loop;}
	if($lsplit[4]=~/[\-\+]/){next loop;}
	my $pp=$lsplit[1]+8260; #convert positions of rCRSplus back to correct 1-16569
	if($pp>16569){$pp=$lsplit[1]-8309;} #convert positions of rCRSplus back to correct 1-16569
	$lsplit[1]=$pp;
	if($lsplit[1]>200 and $lsplit[1]<16400){next loop;}
	$lsplit[7]=~s/ADP\=//;
	$lsplit[7]=~s/\;\S+//; #get total depth
	#if($lsplit[7]<50){next loop;}
	$lsplit[9]=~s/\%\S+//;
	$lsplit[9]=~s/\S+\://; #get %varfreq
	if($lsplit[9]<$PCNT_HOMO){next loop;}	
	if($Variants{$lsplit[1]}{'var'}!~/$lsplit[4]/ and $Variants{$lsplit[1]}{'var'}!~/NA/){print "warning: pos $lsplit[1] hash var $Variants{$lsplit[1]}{'var'} does not match file 2nd var $lsplit[4]!!!\n";}
	$Variants{$lsplit[1]}{'var'}=$lsplit[4];
	if($Variants{$lsplit[1]}{'ref'}!~/$lsplit[3]/){print "warning: pos $lsplit[1] ref $Variants{$lsplit[1]}{'ref'} does not match $lsplit[3]!!!\n";}
}
close INPUT;

##open output file and print sample specific mtDNA sequence in FASTA format
my $outfile2 = $path1."/".$ID.".fasta";
open(OUT2, ">$outfile2") || die "Cannot open file \"$outfile2\" to write to!\n";		
print OUT2 "\>$ID\_homoplasmic$PCNT_HOMO\%\n";

my $c=0;
foreach my $p (sort {$a<=>$b} keys %Variants){	
$c++;
if($Variants{$p}{'var'}=~/NA/){print OUT2 "$Variants{$p}{'ref'}"};
if($Variants{$p}{'var'}!~/NA/){print OUT2 "$Variants{$p}{'var'}"};
#if($c==100){print OUT2 "\n"; $c=0;}
}
unless($c==0){print OUT2 "\n";}
close OUT2;

exit;
