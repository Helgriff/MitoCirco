#!/usr/bin/perl

#Script to calculate variant MAFs from vcf files
my @prefixes=("A","B","C","D","F","H","HV","I","J","K","L","M","N","R","T","U","V","W","X");
my @suffixes=("_SourceBio_Q25_hg38.hg38_multianno.vcf","_SourceBio_Q25_Varscan_hg38.hg38_multianno.vcf");

my $path1="/users/nhrg/lustre/AnalysisScripts/WTCCC10K/Pipeline_MitoCirco/Test_Data"; ##path to directory containing vcf files

my $totsamples=0;
my %mafs;

#($path1, $VCF_prefix, $VCF_suffix)=@ARGV;
#($VCF_prefix)=@ARGV;

foreach my $p (@prefixes){
	foreach my $s (@suffixes){
	my $VCF_prefix=$p;
	my $VCF_suffix=$s;
	my $vcf_file=$path1."/".$VCF_prefix.$VCF_suffix;
	my $numsamples=0;
	
#Read each VCF file genotypes into %mafs
open INPUT2, $vcf_file or die "Cannot open $vcf_file\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		if($Line=~/\#/){next loop2;}
		my @lsplit=split(/\t/,$Line);
		if(!exists $mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}){
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}="NA";
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Het'}=0;
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HomV'}=0;
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HomR'}=0;
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomV'}=":A0:B0:C0:D0:E0:F0:G0:H0:I0:J0:K0:L0:M0:N0:P0:Q0:R0:T0:U0:V0:W0:X0:Y0:Z0:HV0:";
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomR'}=":A0:B0:C0:D0:E0:F0:G0:H0:I0:J0:K0:L0:M0:N0:P0:Q0:R0:T0:U0:V0:W0:X0:Y0:Z0:HV0:";
			$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHet'}=":A0:B0:C0:D0:E0:F0:G0:H0:I0:J0:K0:L0:M0:N0:P0:Q0:R0:T0:U0:V0:W0:X0:Y0:Z0:HV0:";
			}
		for(my $c2=9;$c2<scalar(@lsplit);$c2++){
			my @genoI=split(/\:/,$lsplit[$c2]);
			if($genoI[0]=~/0\/0/){
				$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HomR'}++;
				if($mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomR'}=~/:$VCF_prefix(\d+):/){my $hchr=$1;$hchr++;
														$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomR'}=~s/:$VCF_prefix\d+:/:$VCF_prefix$hchr:/;}	
				}
			if($genoI[0]=~/0\/[123456]/){
				$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Het'}++;
				if($mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHet'}=~/:$VCF_prefix(\d+):/){my $hch=$1;$hch++;
														$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHet'}=~s/:$VCF_prefix\d+:/:$VCF_prefix$hch:/;}
				}
			if($genoI[0]=~/1\/1/ or $genoI[0]=~/2\/2/ or $genoI[0]=~/3\/3/ or $genoI[0]=~/4\/4/ or $genoI[0]=~/5\/5/ or $genoI[0]=~/6\/6/){
				$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HomV'}++;
				if($mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomV'}=~/:$VCF_prefix(\d+):/){my $hchv=$1;$hchv++;
														$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'HgpHomV'}=~s/:$VCF_prefix\d+:/:$VCF_prefix$hchv:/;}	
				}
			if($genoI[0]!~/[\.0123456]\/[\.0123456]/){print "$vcf_file: $Line\n";}
			}#for loop
			
			if($VCF_suffix=~/Varscan/ and $mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}=~/NA/){$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}="Varscan2";}
            if($VCF_suffix=~/Varscan/ and $mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}=~/bcf/){$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}="Both";}
            if($VCF_suffix!~/Varscan/ and $mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}=~/NA/){$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}="bcf";}
            if($VCF_suffix!~/Varscan/ and $mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}=~/Varscan2/){$mafs{$lsplit[0]}{$lsplit[1]}{$lsplit[3]}{$lsplit[4]}{'Call'}="Both";}
			if($numsamples==0){$numsamples=scalar(@lsplit)-9; $totsamples=$totsamples+$numsamples;}
		}#while loop
	close INPUT2;
	}#foreach suffix
}#foreach prefix

#Calculate MAfs and print to file
my $txt_file=$path1."/Haplogroup_MAFs_SourceBio_2492.txt";
my $vcf_outfile=$path1."/Haplogroup_MAFs_SourceBio_2492.vcf";
open(OUT, ">$txt_file") || die "Cannot open file \"$txt_file\" to write to!\n";
open(OUT2, ">$vcf_outfile") || die "Can't open \"$vcf_outfile\" to write to!\n";
print OUT "\#CHROM\tPosition\tREF\tALT\tTotal.Samples\tTotal.Called.Genotypes\tNo.HomoRef\tNo.Hetero\tNo.HomoVar\tMAF\tCalled.By\tHaplogroupCounts.HomR\tHaplogroupCounts.Het\tHaplogroupCounts.HomV\n";
print OUT2 "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tHaplogroupCountsHomR\tHaplogroupCountsHet\tHaplogroupCountsHomV\n";
foreach my $ch (sort keys %mafs){
	foreach my $st (sort {$a<=>$b} keys %{$mafs{$ch}}){
		foreach my $r (sort keys %{$mafs{$ch}{$st}}){
			foreach my $v (sort keys %{$mafs{$ch}{$st}{$r}}){
				my $totgenos=$mafs{$ch}{$st}{$r}{$v}{'Het'}+$mafs{$ch}{$st}{$r}{$v}{'HomV'}+$mafs{$ch}{$st}{$r}{$v}{'HomR'};
				my $MAF=0;
				unless($totgenos==0){$MAF=($mafs{$ch}{$st}{$r}{$v}{'Het'}+(2*$mafs{$ch}{$st}{$r}{$v}{'HomV'}))/($totgenos*2);}
				print OUT "$ch\t$st\t$r\t$v\t$totsamples\t$totgenos\t$mafs{$ch}{$st}{$r}{$v}{'HomR'}\t$mafs{$ch}{$st}{$r}{$v}{'Het'}\t$mafs{$ch}{$st}{$r}{$v}{'HomV'}\t$MAF\t$mafs{$ch}{$st}{$r}{$v}{'Call'}\t$mafs{$ch}{$st}{$r}{$v}{'HgpHomR'}\t$mafs{$ch}{$st}{$r}{$v}{'HgpHet'}\t$mafs{$ch}{$st}{$r}{$v}{'HgpHomV'}\n";
				print OUT2 "$ch\t$st\t$mafs{$ch}{$st}{$r}{$v}{'Call'}\t$r\t$v\t200\tPASS\tTS\=$totsamples\;TG\=$totgenos\;HmR\=$mafs{$ch}{$st}{$r}{$v}{'HomR'}\;Ht\=$mafs{$ch}{$st}{$r}{$v}{'Het'}\;HmV\=$mafs{$ch}{$st}{$r}{$v}{'HomV'}\;MAF\=$MAF\tGT\:A\:B\:C\:D\:E\:F\:G\:H\:I\:J\:K\:L\:M\:N\:P\:Q\:R\:T\:U\:V\:W\:X\:Y\:Z\:HV\:\t0\/0$mafs{$ch}{$st}{$r}{$v}{'HgpHomR'}\t0\/1$mafs{$ch}{$st}{$r}{$v}{'HgpHet'}\t1\/1$mafs{$ch}{$st}{$r}{$v}{'HgpHomV'}\n";
			}
		}
	}
}
close OUT;
close OUT2;
exit;
