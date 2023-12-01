open I, "<$ARGV[0]";
#open O, ">$ARGV[0].seq";
open O2, ">$ARGV[0].txt";

while(<I>){
chomp;
$seq=<I>;
chomp($seq);
<I>;
<I>;
$length=length($seq);
#print O "$seq\n";
$total+=$length;
}
print O2 "total bp:\t$total\n";


