#!/usr/bin/perl
open O, ">motif.tsv";
print O "motif\tcount\ttotal\tpercentage\n";

sub search{
open I, "<$ARGV[0]";
$motif2=$motif;
open O2, ">b6-seq-motif/$motif2.txt";
$motif=~s/A/[A]/gi;
$motif=~s/T/[T]/gi;
$motif=~s/G/[G]/gi;
$motif=~s/C/[C]/gi;
$motif=~s/R/[AG]/gi;
$motif=~s/M/[AC]/gi;
$motif=~s/K/[GT]/gi;
$motif=~s/S/[CG]/gi;
$motif=~s/W/[AT]/gi;
$motif=~s/Y/[CT]/gi;
$motif=~s/H/[ACT]/gi;
$motif=~s/D/[ATG]/gi;
$motif=~s/B/[CGT]/gi;
$motif=~s/V/[ACG]/gi;
$motif=~s/N/[ATGC]/gi;

print "$motif2\n";
$n=0;
$total=0;
while(<I>){
chomp;
$name=$_;
$bindseq=<I>;
$total++;
if($bindseq=~/$motif/){
$n++;
print O2 "$name\n$bindseq";
#print "$name\n$bindseq";
}


}
$per=$n/$total*100;

#print "$motif2\t$n\t$total\t$per\n";
print O "$motif2\t$n\t$total\t$per\n";
close I;
}

$motif='TCTAGA';
search;
$motif='CRAANNNNNNNNCTT';
search;
$motif='AAGNNNNNNNNTTYG';
search;
$motif='CRAANNNNNNNNNTTC';
search;
$motif='GAANNNNNNNNNTTYG';
search;
$motif='CRAANNNNNNNNCTG';
search;
$motif='CAGNNNNNNNNTTYG';
search;
 $motif='CACNNNNNNNCTG';
search;
 $motif='CAGNNNNNNNGTG';
search;
$motif='CACNNNNNNNNTTC';
search;
 $motif='GAANNNNNNNNGTG';
search;
 $motif='CACNNNNNNNCTT';
search;
 $motif='AAGNNNNNNNGTG';
search;
 $motif='TGANNNNNNNTATC';
search;
 $motif='GATANNNNNNNTCA';
search;
 $motif='GGANNNNNNNTGA';
search;
 $motif='TCANNNNNNNTCC';
search;
 $motif='GGANNNNNNNTCA';
search;
 $motif='TGANNNNNNNTCC';
search;
 $motif='GAYNNNNNNTCC';
search;
 $motif='GGANNNNNNRTC';
search;
 $motif='GATANNNNNNRTC';
search;
 $motif='GAYNNNNNNTATC';
search;
 $motif='TCANNNNNNRTAC';
search;
 $motif='GTAYNNNNNNTGA';
search;
