open I, "<$ARGV[0]";
open O, ">$ARGV[0].sig.txt";

$start=0;

while(<I>){

chomp;
#print "$_\n";
#
if($_=~/\(0\): "(@.*? )/)
{
$name=$1;
$start++;
if($start < 2)
{
print O "$name\n";
}else{
print O "\n$name\n";
}
}


if($_=~/\(\d+\): (\d+,.*?)$/)
 {
$info=$1;
print O $info;
#print "$_\n";
#print "$info\n";
@info=split /,/,$info;
foreach(@info)
	{
	#print O "$_,";
	}
 }

}
#print O "\n";


