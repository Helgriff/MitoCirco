#!/usr/bin/perl

#Script to sort a directory of (bam) files into per haplogroup directories

my $path1="/home/nhrg/WORKING_DATA/SourceBio/BAMs"; ##path to directory containing multiple indexed bam files
my $HapIDfile="SB_MajorHG_2492_Jan2016.txt"; ##tab delim text file with column1 containing bam file/sample IDs and Column2 lists Major mtDNA haplogroup of sample
my $Bam_suffix="_nodups_hg38.bam";

($path1, $HapIDfile, $Bam_suffix)=@ARGV;

#define variables
my @DirContent=`ls $path1`;
my %IDs;
my %Haps;

#Read ID/Haplogroup file into %
open INPUT2, $HapIDfile or die "Cannot open $HapIDfile\n";
	loop2: while (<INPUT2>){
		my $Line=$_;
		chomp $Line;
		my @lsplit=split(/\t/,$Line);
		if(!exists $IDs{$lsplit[0]}){$IDs{$lsplit[0]}=$lsplit[1];} #key=ID,value=Haplogroup
		if(!exists $Haps{$lsplit[1]}){$Haps{$lsplit[1]}=0; `mkdir $path1/$lsplit[1]`}
		$Haps{$lsplit[1]}++;
}
close INPUT2;

#Move Files into per haplogroup directories
foreach my $file (@DirContent){
		chomp($file);
		if($file=~/(\S+)$Bam_suffix/){
		my $id=$1;
		if(exists $IDs{$id}){`mv "$path1/$file" "$path1/$IDs{$id}/"`;}
		}
}

#Output Haplogroups and file/ID counts	
print "Haplogroup\tCount\n";
foreach my $h (sort keys %Haps){
	print "$h\t$Haps{$h}\n";
	}

exit;
