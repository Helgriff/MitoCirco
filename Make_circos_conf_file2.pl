#!/usr/bin/perl -w
use strict;
use warnings;

#Program to make circos.conf file

my($path1, $ID, $dir)=@ARGV;

my $CIRC_CONFILE=$path1."/circos2.conf";
my $DEPTHmt_FILE=$path1."/Depthmt.txt"; #hg38-rCRS
my $DEPTHmtonly_FILE=$path1."/Depthmtonly.txt"; #rCRS
my $VARSmt_FILE=$path1."/Varsmt.txt";
my $VARSmtonly_FILE=$path1."/Varsmtonly.txt";
my $MSKhet_FILE=$path1."/MSKhets_Sig1p.txt";

my $png=$path1."/".$ID."circos2.png";

open(OUT, ">$CIRC_CONFILE") || die "Cannot open file \"$CIRC_CONFILE\" to write to!\n";

print OUT "
\<\<include $dir\/CircosFiles\/housekeeping.conf\>\>
anti_aliasing\* \= no
max_points_per_track\* \= 30000
\<\<include $dir\/CircosFiles\/colors_fonts_patterns.conf\>\>
\<\<include $dir\/CircosFiles\/ideogram2.conf\>\>
\<\<include $dir\/CircosFiles\/ticks2.conf\>\>
\<\<include $dir\/CircosFiles\/karyotype2.conf\>\>
karyotype\* \= $dir\/CircosFiles\/karyotype.human.txt
\<image\>
angle_offset\* \= \-90
file\*  \= $png
svg\*   \= no
\<\<include $dir\/CircosFiles\/image.conf\>\>
\<\/image\>
\<plots\>

\#chrM read depths
\<plot\>
type		\= scatter
file		\= $DEPTHmt_FILE
r1			\= 0.99r
r0			\= 0.84r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<backgrounds\>
\<background\>
chromosomes	\= hsM
color	\= vvlgrey
y1		\= 1r
y0		\= 0r
\<\/background\>
\<\/backgrounds\>
\<\/plot\>

\#chrM variants
\<plot\>
type		\= scatter
file		\= $VARSmt_FILE
r1			\= 0.83r
r0			\= 0.68r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>

\<plot\>
type		\= scatter
file		\= $MSKhet_FILE
r1			\= 0.83r
r0			\= 0.68r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>

\<plot\>
type		\= scatter
file		\= $DEPTHmtonly_FILE
r1			\= 0.67r
r0			\= 0.53r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<backgrounds\>
\<background\>
chromosomes	\= hsM
color	\= vvlgrey
y1		\= 1r
y0		\= 0r
\<\/background\>
\<\/backgrounds\>
\<\/plot\>

\<plot\>
type		\= scatter
file		\= $VARSmtonly_FILE
r1			\= 0.52r
r0			\= 0.38r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>
\<\/plots\>\n";
close OUT;
exit;
