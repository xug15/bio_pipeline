open I, "<$ARGV[0]";
open O, ">$ARGV[0].txt";
<I>;
print O "bamFiles\treadLengths\tOffsets\tbamLegends\n";
while(<I>){
chomp;
if($_=~/^$/){
next;
}
@data=split /\t/,$_;
$data[0]=~s/Aligned.toTranscriptome.out//g;
print O "$data[1].sort.bam\t$data[3]\t$data[4]\t$data[0]\n";
}

close I;
close O;



