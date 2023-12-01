open I, "<$ARGV[0]";
open O, ">$ARGV[0].fq";

$start=0;

while(<I>){

chomp;

if($_=~/\(0\): "(@.*?$)/)
{
$name=$1;
$seq=<I>;
$seq=~s/\s+//g;

<I>;
$qua=<I>;
$qua=~s/\s+//g;
print O "$name\n";
print O "$seq\n";
print O "+\n";
print O "$qua\n";


}



}


