#!/usr/bin/perl -w
use strict;
use warnings;

#Program to make circos.conf file

my($path1, $ID, $dir)=@ARGV;

my $CIRC_CONFILE=$path1."/circos.conf";
my $LINKncmt_FILE=$path1."/Linkncmt_".$ID.".txt";
# my $LINKnc_FILE=$path1."/Linknc_".$ID.".txt";
my $DEPTHmt_FILE=$path1."/Depthmt.txt";
my $DEPTHnc_FILE=$path1."/Depthnc.txt";
my $VARSmt_FILE=$path1."/Varsmt.txt";
my $VARSnc_FILE=$path1."/Varsnc.txt";
my $MSKhet_FILE=$path1."/MSKhets_Sig1p.txt";

my $png=$path1."/".$ID."_circos1.png";

open(OUT, ">$CIRC_CONFILE") || die "Cannot open file \"$CIRC_CONFILE\" to write to!\n";

print OUT "
\<\<include $dir\/CircosFiles\/housekeeping.conf\>\>
anti_aliasing\* \= no
max_points_per_track\* \= 90000
\<\<include $dir\/CircosFiles\/colors_fonts_patterns.conf\>\>
\<\<include $dir\/CircosFiles\/ideogram.conf\>\>
\<\<include $dir\/CircosFiles\/ticks.conf\>\>
\<\<include $dir\/CircosFiles\/karyotype.conf\>\>
karyotype\* \= $dir\/CircosFiles\/karyotype.human.txt
\<image\>
angle_offset\* \= \-88
file\*  \= $png
svg\*   \= no
\<\<include $dir\/CircosFiles\/image.conf\>\>
\<\/image\>

\#mtDNA -> nuclear links
\<links\>
ribbon           \= no
bezier_radius    \= 0r
crest                \= 0.25
bezier_radius_purity \= 0.5
\<link\>
file		\= $LINKncmt_FILE
radius		\= 0.60r
thickness	\= 4
\<\/link\>
\<\/links\>

\<plots\>
\#chrM read depths
\<plot\>
type		\= scatter
file		\= $DEPTHmt_FILE
r1			\= 0.87r
r0			\= 0.77r
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

\#Nuclear read depths
\<plot\>
type		\= scatter
file		\= $DEPTHnc_FILE
r1			\= 0.87r
r0			\= 0.77r
\<axes\>
chromosomes	\= \/hs\[1\-9\,X\,Y\]/
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>

\#chrM variants homoP from Varscan and HeteroP from MitoSeek
\<plot\>
type		\= scatter
file		\= $VARSmt_FILE
r1			\= 0.65r
r0			\= 0.61r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>

\#chrM MSK heteroP
\<\/plot\>
\<plot\>
type		\= scatter
file		\= $MSKhet_FILE
r1			\= 0.65r
r0			\= 0.61r
\<axes\>
chromosomes	\= hsM
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>

\#Nuclear variants
\<plot\>
type		\= scatter
file		\= $VARSnc_FILE
r1			\= 0.65r
r0			\= 0.61r
\<axes\>
chromosomes\t\= \/hs\[1\-9\,X\,Y\]\/
\<\<include $dir\/CircosFiles\/axis.conf\>\>
\<\/axes\>
\<\/plot\>

\# chrM Complex
\<plot\>
type            \= text
file            \= $dir\/CircosFiles\/MitoComplex.txt
r1                      \= 0.92r
r0                      \= 0.88r
label_font \= light
label_size \= 16p
label_rotate \= yes
\<backgrounds\>
\<background\>
chromosomes    \= hsM
color   \= vvlred
y1              \= 1r
y0              \= 0r
\<\/background\>
\<\/backgrounds\>
\<axes\>
chromosomes     \= hsM
\<\/axes\>
\<\/plot\>

\#NCBI 14400 MitoSequences variant Frequency
\<plot\> 
type      \= histogram
file      \= $dir\/CircosFiles\/NCBI_14400_Freq.txt
r1        \= 0.77r
r0        \= 0.65r
extend_bin \= no
color      \= black
min        \= 0
max        \= 1
\<rules\>
\<rule\>
condition \= var\(value\) \<\= 0.01
color \= red
\<\/rule\>
\<rule\>
condition \= var\(value\) \> 0.05
color \= purple
\<\/rule\>
\<rule\>
condition \= var\(value\) \> 0.01 \&\& var\(value\) \<\= 0.05
color \= red
\<\/rule\>
\<\/rules\>
\<\/plot\>

\# Nuclear Mito mtDNA Genes
\<plot\>
type            \= text
file            \= $dir\/CircosFiles\/MitoGenesNuclear1598.txt
r1                      \= 0.99r
r0                      \= 0.92r
label_font \= light
label_size \= 16p
\<backgrounds\>
\<background\>
#chromosomes    \=  \/hs\[1\-9\,X\,Y\]\/
color   \= vvlgreen
y1              \= 1r
y0              \= 0r
\<\/background\>
\<\/backgrounds\>
\<axes\>
#chromosomes     \=  \/hs\[1\-9\,X\,Y\]\/
\<\/axes\>
\<\/plot\>

\# chrM Gene tiles
\<plot\>
type            \= tile
file            \= $dir\/CircosFiles\/MitoGenes_tile.txt
r1                      \= 0.99r
r0                      \= 0.88r
orientation             \= centre
layers                  \= 40
margin                  \= 0.005u
thickness               \= 2
padding                 \= 1
layers_overflow         \= collapse
layers_overflow_color   \= green
stroke_thickness        \= 1
stroke_color            \= dgreen
color                   \= green
\<\/plot\>

\<\/plots\>\n";
close OUT;
exit;

### Green Links file
#\<link\>
#file		\= $LINKnc_FILE
#radius		\= 0.60r
#thickness	\= 4
#\<\/link\>
