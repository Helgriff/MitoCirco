#!/usr/bin/perl
use strict;
use warnings;

my ($sample_path, $sample_id)  = @ARGV;

#print "$sample_path $sample_id\n";

$sample_path =~ s/\/$//;
my $folder=$sample_path."/".$sample_id;
my $lanes="";
my %cucu_lane;
opendir (DIR, $folder) or die "Can't find the directory $folder";
while (my $file = readdir(DIR)) {
	next if ($file =~ m/^\./);
	
	if($file =~ m/$sample_id\S+L00(\d+)\_R1.+\.fastq/) {
		my $lane_temp=$1;
		if (! exists $cucu_lane{$lane_temp}) {
			$lanes=$1." ".$lanes;
			$cucu_lane{$lane_temp} = 1;
		}
	}
}
close DIR;
chomp $lanes;
print $lanes."\n";
exit;
